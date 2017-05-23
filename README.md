# WHMCS Notes

## WHMCS Settings

**General Setings -> Other ->**: Only require First & Last name on client registration

## Development Instances

**API Credentials**:
```
Identifier:  mpto32mPUQoRC9EE19Vq1MF3t7K2jofd
Secret:      dxS1eqY7okcbPIjSggXnu8Ygd0Wysv9f
```

#### WHMCS Network (to make sure the ip does not change for licensing reasons)

```
docker network create --driver bridge --subnet 192.168.200.0/24 net1
```

```
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=pass123! -e MYSQL_DATABASE=whmcs mysql:5.6
docker run -d --name whmcs -p 3001:80 --net net1 --ip 192.168.200.50 -v /home/kwatson/whmcs:/var/www/html/whmcs cmptstks/whmcs
```

# Examples
```
Whmcs.configure_with('config-sample.yml')
response = Whmcs::Client.new.authenticated_url({:email=>"kris2@lumo.us", :goto=>"viewinvoice.php?id=1"})

u = Whmcs::User.find(1)
products = [{'label' => 'my-service', 'product_id' => 1, 'qty' => 1}]
order = Whmcs::Order.new
order.user = u
order.products = products
order.user_ip = '127.0.0.1'
```