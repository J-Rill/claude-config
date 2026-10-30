"""Attrition tracker — log how many observations survive each pipeline step.

Copy this file into your project (e.g. src/attrition.py) and use it in the Python
cleaning stage to produce an auditable sample-construction table. Every dropped
observation ends up accounted for with a reason, which is exactly what a referee
(or you, later) will ask for.

    from attrition import Attrition

    att = Attrition("sample")
    att.step("raw Ritter events", len(df))
    df = df[df["offer_price"] >= 5]
    att.step("drop penny stocks", len(df), why="offer price < $5")
    df = df.merge(crsp, on="permno", how="inner")
    att.step("matched to CRSP", len(df), why="permno present in crsp.msenames")
    att.write()                       # -> output/attrition_sample.csv
    # or att.write("output/attrition_02_match.csv") for an explicit path

Output CSV columns: step, n_remaining, n_dropped, why.
n_dropped is filled automatically from the previous step's n_remaining when you
don't pass it explicitly (blank on the first step). A merge that *expands* the
sample shows a negative n_dropped — informative, not an error — so pass n_dropped
explicitly if you want a different accounting.
"""

import csv
import numbers
from pathlib import Path


class Attrition:
    def __init__(self, name):
        self.name = name
        self.rows = []  # each row: {step, n_remaining, n_dropped, why}

    def step(self, step, n_remaining, n_dropped=None, why=""):
        # Loud on misuse — a non-integer count means the caller passed the wrong
        # thing (e.g. a DataFrame/Series instead of len(df)), and we want to fail
        # now, not later. numbers.Integral accepts both Python int and numpy int
        # types (what .sum()/.count()/groupby counts return), and rejects floats
        # and non-scalars.
        assert isinstance(n_remaining, numbers.Integral), (
            f"n_remaining must be an integer count, got {type(n_remaining).__name__} "
            f"for step {step!r}"
        )
        n_remaining = int(n_remaining)  # normalize numpy int -> clean CSV value
        # Infer rows dropped from the previous step when not given explicitly.
        if n_dropped is None and self.rows:
            n_dropped = self.rows[-1]["n_remaining"] - n_remaining
        self.rows.append({
            "step": step,
            "n_remaining": n_remaining,
            "n_dropped": "" if n_dropped is None else int(n_dropped),
            "why": why,
        })

    def write(self, path=None):
        assert self.rows, "no attrition steps recorded — call .step() before .write()"
        path = Path(path) if path is not None else Path("output") / f"attrition_{self.name}.csv"
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["step", "n_remaining", "n_dropped", "why"])
            writer.writeheader()
            writer.writerows(self.rows)
        return path
