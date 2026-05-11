# Security & Environment Management

## Secret Management
- NEVER commit secrets to git (use .env + .gitignore)
- Use environment variables for all secrets (API keys, DB passwords, tokens)
- Different credentials per environment (dev ≠ staging ≠ prod)
- Rotate credentials on a schedule (90 days max)
- Use a secret manager in production (AWS Secrets Manager, Vault, 1Password)

## .env File Conventions
```
# .env.example (committed — documents required vars)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
API_KEY=your-api-key-here
JWT_SECRET=your-jwt-secret

# .env (gitignored — contains actual values)
DATABASE_URL=postgresql://real-user:real-pass@db.example.com:5432/prod
```

## OWASP Top 10 Quick Checks
1. **Injection**: Parameterize all queries, never concatenate user input
2. **Broken Auth**: Hash passwords (bcrypt/argon2), use secure sessions
3. **Sensitive Data**: Encrypt at rest and in transit (TLS)
4. **XXE**: Disable external entity processing in XML parsers
5. **Access Control**: Check permissions on every request, principle of least privilege
6. **Misconfig**: No default credentials, disable debug in production
7. **XSS**: Escape all user output, use CSP headers
8. **Deserialization**: Validate and sanitize all deserialized input
9. **Components**: Keep dependencies updated, audit with `npm audit`
10. **Logging**: Log security events, never log secrets or PII

## Input Validation
- Validate at system boundaries (API endpoints, form submissions)
- Whitelist allowed values, don't blacklist dangerous ones
- Validate type, length, format, and range
- Return generic error messages to users (no stack traces)
