### Local Development Helper for Laravel using Nginx / PHP 7.3 / Self Signed Certificates

Found myself doing this way too often, so I decided to learn bash and setup a script to automate it.

Fairly easy to use, just ` ./create.sh `

Next, select the type of nginx file you are trying to create.
    
- SSL (doesn't generate a cert and assumes /etc/ssl/domain.key)
- SSLGen (creates a cert with mkcert and moves to /etc/ssl)
- HTTP (doesn't use any ssl)

It will then prompt you for your development url (i.e. project.test)

Then your folder name of your /var/www/html (i.e. project for /var/www/html/project)

Ties in well with this bashrc function

```
lnew() {
   laravel new $1
   cd $1
   composer require laravel/ui --dev
   php artisan ui vue --auth
   composer require laravel/telescope --dev
   composer require --dev barryvdh/laravel-ide-helper
   php artisan telescope:install
   git init
   git add .
   git commit -m "Install Laravel"
   npm install
   npm run dev
}

./create.sh
```