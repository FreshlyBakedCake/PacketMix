# SPDX-FileCopyrightText: 2021 Daniele Nicolodi
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: GPL-2.0-only

from smart_importer import PredictPayees, PredictPostings
from beangulp.importers import csvbase

import mimetypes
import os
import pathlib

class FlagColumn(csvbase.Column):
    def __init__(self, *names, statuses=None, default=None):
        if default is None:
            super().__init__(*names) # We can't set default=NA because we can't access it from here (apparently?)
        else:
            super().__init__(*names, default=default)
        
        if statuses is None:
            self.statuses = {}
        else:
            self.statuses = statuses

    def parse(self, value):
        return self.statuses.get(value.strip(), self.default)

class PNCImporter(csvbase.Importer):
    name = "PNC"

    amount = csvbase.Amount("Total")
    balance = csvbase.Amount("Balance")
    currency = csvbase.Column("Currency")
    date = csvbase.Date("Date", "%m/%d/%Y")
    flag = FlagColumn("Status", statuses={ "Completed": "*" }, default="!")
    narration = csvbase.Columns("Type", "Transaction ID", "Item Title", sep="; ")
    payee = csvbase.Column("Name")
    encoding = "utf-8-sig"

    def identify(self, filepath):
        mimetype, encoding = mimetypes.guess_type(filepath)
        if mimetype != "text/csv":
            return False
        with open(filepath, encoding=self.encoding) as fd:
            head = fd.read(1024)
        return head.startswith(
            '"Date","Time","TimeZone","Name","Type","Status","Currency","Gross","Fees","Total","Exchange Rate","Receipt ID","Balance","Transaction ID","Item Title"'
        )

    def filename(self, filepath):
        return "pnc." + os.path.basename(filepath)
        

CONFIG = [
    PNCImporter("Assets:Accounts:PNC:Main:Checking", "USD"),
]

HOOKS = [
    PredictPayees().hook,
    PredictPostings().hook,
]
