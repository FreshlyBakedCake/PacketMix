# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

import autobean.truelayer
from smart_importer import apply_hooks, PredictPayees, PredictPostings

import os
import pathlib

with open(pathlib.Path(os.environ["CREDENTIALS_DIRECTORY"]) / pathlib.Path("truelayer_client_secret")) as f:
  truelayer_client_secret = f.read().strip()

CONFIG = [
  apply_hooks(
    autobean.truelayer.Importer(
      "fava-228732",
      truelayer_client_secret
    ),
    [
      PredictPayees(),
      PredictPostings(),
    ]
  )
]
