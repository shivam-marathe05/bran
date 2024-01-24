# bran
A django app

# setup 

```bash
cd backend
python manage.py migrate
python manage.py runserver
```

- On app start it loads .env file for the configuration 
- By default it uses sqlite db, you can provide valid [URL schema](https://github.com/jazzband/dj-database-url/#url-schema) to use postgres/mysql
- http://127.0.0.1:8000/bran/* will return list users stored in db
- http://127.0.0.1:8000/metrics - returns app metrics
