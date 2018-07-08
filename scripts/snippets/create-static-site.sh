# variables: $domain

echo "Creating user + group for ${domain}..."
sudo useradd --no-create-home ${domain} --shell /bin/false
# add admin users to new group
for user in $(ls /home) ; do sudo usermod -a -G ${domain} ${user} ; done
# and ngnix
sudo usermod -a -G ${domain} www-data

echo "Creating site directory (/srv/${domain})"
sudo mkdir -p /srv/${domain}/public
sudo chown -R ${domain}:${domain} /srv/${domain}
sudo chmod g+srw /srv/${domain}
sudo chmod g+srw /srv/${domain}/public

echo 'Configuring nginx...'
sudo cp /srv/.templates/static-site.nginx.conf /etc/nginx/sites-available/${domain}
sudo sed -i -e s/{{domain}}/${domain}/g /etc/nginx/sites-available/${domain}
sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/${domain}

echo 'Restarting nginx...'
sudo systemctl restart nginx

# without index file, nginx will display a 403 error when accessing the site.
# We'll put something there so that we can at least see a page to see if the
# site was properly setup
echo "<h1>$domain ready to go!</h1>" | sudo tee /srv/${domain}/public/index.html > /dev/null
chown ${domain}:${domain} /srv/${domain}/public/index.html
chmod g+rw /srv/${domain}/public/index.html
