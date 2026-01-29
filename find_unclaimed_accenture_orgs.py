"""
Find unclaimed Accenture organizations in Salesforce with spend > $10,000.

Usage:
    # Set environment variables (or create a .env file):
    export SF_INSTANCE_URL="https://your-org.salesforce.com"
    export SF_ACCESS_TOKEN="your-oauth-access-token"

    # Run:
    python find_unclaimed_accenture_orgs.py

    # Optional flags:
    python find_unclaimed_accenture_orgs.py --output results.csv   # Export to CSV
    python find_unclaimed_accenture_orgs.py --min-spend 25000      # Override spend threshold
"""

import argparse
import csv
import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SPEND_THRESHOLD = 10_000  # default minimum spend in USD


# NOTE: Adjust the following to match your Salesforce schema:
#   SPEND_FIELD  – the API name of the custom spend field on Account
#                  (common alternatives: Annual_Spend__c, Total_Spend__c, Spend__c)
#   OWNER_FILTER – the condition that identifies "unclaimed" accounts.
#                  Common patterns:
#                    Owner.Name = 'Unassigned'
#                    OwnerId = null
#                    Owner_Custom__c = 'Unclaimed'
#                  Defaulting to OwnerId = null here as the safest general case.
SPEND_FIELD = os.environ.get("SF_SPEND_FIELD", "Annual_Spend__c")
OWNER_FILTER = os.environ.get("SF_OWNER_FILTER", "OwnerId = null")

SOQL_TEMPLATE = """
SELECT
    Id,
    Name,
    BillingCity,
    BillingState,
    BillingCountry,
    Industry,
    AnnualRevenue,
    NumberOfEmployees,
    Phone,
    Website,
    OwnerId,
    Owner.Name,
    CreatedDate,
    LastModifiedDate,
    {spend_field}
FROM Account
WHERE Name LIKE '%Accenture%'
  AND {owner_filter}
  AND {spend_field} > {spend_threshold}
ORDER BY {spend_field} DESC
""".strip()


# ---------------------------------------------------------------------------
# Salesforce REST helpers
# ---------------------------------------------------------------------------


def _make_request(url: str, token: str) -> dict:
    """Issue an authenticated GET and return the parsed JSON response."""
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/json")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def soql_query(instance_url: str, token: str, soql: str) -> list[dict]:
    """
    Execute a SOQL query and return all result records,
    automatically following pagination (nextRecordsUrl).
    """
    encoded = urllib.parse.quote(soql, safe="")
    url = f"{instance_url}/services/data/v59.0/query?q={encoded}"

    records: list[dict] = []
    while url:
        data = _make_request(url, token)
        records.extend(data.get("records", []))
        next_url = data.get("nextRecordsUrl")
        url = f"{instance_url}{next_url}" if next_url else None

    return records


# ---------------------------------------------------------------------------
# Formatting & output
# ---------------------------------------------------------------------------

COLUMNS = [
    "Id",
    "Name",
    "BillingCity",
    "BillingState",
    "BillingCountry",
    "Industry",
    "AnnualRevenue",
    "NumberOfEmployees",
    "Phone",
    "Website",
    "OwnerId",
    "OwnerName",
    "CreatedDate",
    "LastModifiedDate",
    "AnnualSpend",
]


def flatten(record: dict) -> dict:
    """Flatten nested Owner object and rename custom field for CSV output."""
    owner = record.get("Owner") or {}
    return {
        "Id": record.get("Id"),
        "Name": record.get("Name"),
        "BillingCity": record.get("BillingCity"),
        "BillingState": record.get("BillingState"),
        "BillingCountry": record.get("BillingCountry"),
        "Industry": record.get("Industry"),
        "AnnualRevenue": record.get("AnnualRevenue"),
        "NumberOfEmployees": record.get("NumberOfEmployees"),
        "Phone": record.get("Phone"),
        "Website": record.get("Website"),
        "OwnerId": record.get("OwnerId"),
        "OwnerName": owner.get("Name"),
        "CreatedDate": record.get("CreatedDate"),
        "LastModifiedDate": record.get("LastModifiedDate"),
        "AnnualSpend": record.get(SPEND_FIELD),
    }


def print_table(rows: list[dict]) -> None:
    """Print a human-readable summary table to stdout."""
    if not rows:
        print("\nNo matching records found.")
        return

    header = f"{'#':<4} {'Name':<45} {'City':<20} {'Industry':<22} {'Annual Spend':>14}"
    print("\n" + header)
    print("-" * len(header))
    for i, row in enumerate(rows, 1):
        spend = row.get("AnnualSpend")
        spend_str = f"${spend:,.2f}" if spend else "N/A"
        print(
            f"{i:<4} {(row.get('Name') or ''):<45} "
            f"{(row.get('BillingCity') or ''):<20} "
            f"{(row.get('Industry') or ''):<22} "
            f"{spend_str:>14}"
        )
    print(f"\nTotal unclaimed Accenture orgs with spend > threshold: {len(rows)}")


def write_csv(rows: list[dict], path: str) -> None:
    """Write flattened records to a CSV file."""
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)
    print(f"\nExported {len(rows)} records to {path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(
        description="Find unclaimed Accenture orgs in Salesforce with spend > threshold."
    )
    parser.add_argument(
        "--output", "-o", default=None, help="Optional CSV file path for export"
    )
    parser.add_argument(
        "--min-spend",
        type=float,
        default=SPEND_THRESHOLD,
        help=f"Minimum annual spend threshold (default: {SPEND_THRESHOLD:,})",
    )
    args = parser.parse_args()

    # --- credentials from env ---
    instance_url = os.environ.get("SF_INSTANCE_URL", "").rstrip("/")
    access_token = os.environ.get("SF_ACCESS_TOKEN", "")

    if not instance_url or not access_token:
        print(
            "ERROR: SF_INSTANCE_URL and SF_ACCESS_TOKEN environment variables are required.\n"
            "  export SF_INSTANCE_URL=\"https://your-org.salesforce.com\"\n"
            "  export SF_ACCESS_TOKEN=\"your-oauth-access-token\"",
            file=sys.stderr,
        )
        sys.exit(1)

    # --- build & run query ---
    query = SOQL_TEMPLATE.format(
        spend_field=SPEND_FIELD,
        owner_filter=OWNER_FILTER,
        spend_threshold=args.min_spend,
    )
    print(f"[{datetime.now(timezone.utc).isoformat()}] Querying Salesforce...")
    print(f"  Instance : {instance_url}")
    print(f"  Threshold: ${args.min_spend:,.2f}")

    records = soql_query(instance_url, access_token, query)
    rows = [flatten(r) for r in records]

    # --- display ---
    print_table(rows)

    # --- optional CSV export ---
    if args.output:
        write_csv(rows, args.output)


if __name__ == "__main__":
    main()
