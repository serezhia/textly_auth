# Textly auth service 🔐

# Passwordless email auth service for textly

Features:
1. Limit email sent per second
2. Auto-block account with inccorect password
3. JWT tokens

Build: 

1. Create .env file with 
      - MAIL_LOGIN
      - MAIL_PASSWORD
      - SMTP_MAIL
      - SECRET_KEY
      - AUTH_PORT
      - AUTH_HOST
      - AUTH_DATABASE_HOST
      - AUTH_DATABASE_PORT
      - AUTH_DATABASE_NAME
      - AUTH_DATABASE_USERNAME
      - AUTH_DATABASE_PASSWORD

2. Build server.dart with dart_frog
```
dart_frog build
```

3. Copy root Dockerfile to ./build/

4. Docker build --ssh Default or Docker compose build --ssh Default 

5. docker run or docker compose up