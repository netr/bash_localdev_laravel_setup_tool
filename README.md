### Local Development Helper for Nginx / PHP 7.3 / Self Signed Certificates

Found myself doing this way too often, so I decided to learn bash and setup a script to automate it.

Fairly easy to use, just ` ./create.sh `

Next, select the type of nginx file you are trying to create.
    
- SSL (doesn't generate a cert and assumes /etc/ssl/domain.key)
- SSLGen (creates a cert with mkcert and moves to /etc/ssl)
- HTTP (doesn't use any ssl)

It will then prompt you for your development url (i.e. project.test)

Then your folder name of your /var/www/html (i.e. project for /var/www/html/project)

Enjoy