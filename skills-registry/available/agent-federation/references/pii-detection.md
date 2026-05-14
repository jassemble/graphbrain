# PII Detection Patterns

Detect and redact these 14 PII types on every outbound message:

| Type | Pattern (regex shorthand) | Redaction |
|------|---------------------------|-----------|
| SSN | `\b\d{3}-\d{2}-\d{4}\b` | `<PII:SSN>` |
| Credit card | `\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b` + Luhn check | `<PII:CC>` |
| Email | `[\w.+-]+@[\w-]+\.[\w.-]+` | `<PII:EMAIL>` |
| Phone (US) | `\b\d{3}[-.]?\d{3}[-.]?\d{4}\b` | `<PII:PHONE>` |
| Address | NER model (street + city + state + zip) | `<PII:ADDR>` |
| IP address | `\b(?:\d{1,3}\.){3}\d{1,3}\b` | `<PII:IP>` |
| DOB | `\b\d{1,2}/\d{1,2}/\d{2,4}\b` (with date validation) | `<PII:DOB>` |
| Government ID | Country-specific patterns (passport, driver's license) | `<PII:GOV_ID>` |
| Name | NER model (PERSON entity) | `<PII:NAME>` |
| Medical record | `MRN:\s*\d+` or pattern lookup | `<PII:MRN>` |
| Bank account | `\b\d{8,17}\b` (with routing context) | `<PII:ACCT>` |
| Biometric | Detect file uploads with biometric metadata | `<PII:BIO>` |
| Passport | `[A-Z]\d{7,9}` (country-dependent) | `<PII:PASSPORT>` |
| Driver's license | Country-specific patterns | `<PII:DL>` |

## Implementation Rules

1. **Whitelist over blacklist**: prefer redacting unknown patterns over missing known PII
2. **Validate before redacting**: e.g., Luhn check for credit cards reduces false positives
3. **Preserve structure**: redact the value, keep the field name (helps recipient understand)
4. **Log every redaction**: timestamp, type, source, target — for audit
5. **Test with real-shape data**: don't trust `{ ssn: "xxx-xx-xxxx" }` fixtures

## Limitations

- Free-form text PII (e.g., name buried in narrative) is hard to detect — use NER models
- Unicode and homoglyph attacks can bypass regex (e.g., Cyrillic 'е' vs Latin 'e')
- Compound PII (just initials + ZIP + DOB can re-identify) is not caught by per-field detection
- Context leakage via LLM provider remains a separate concern
