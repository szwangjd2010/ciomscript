# user admin on any db
```
use admin
db.createUser(
{
	"user" : "admin",
	"pwd": "YDVpwdasdwx2910",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
)
```

# read wirte on any db
```
use admin
db.createUser(
{
	"user" : "datav",
	"pwd": "YDVpwdasdwx2910",
	"roles" : [
		"readWriteAnyDatabase"
	]
}
)
```


# user on special db
```
use db01
db.createUser(
{
	user:"oneUser",
	pwd:"12345",
	roles:[
		{role:"read",db:"db01"},
		{role:"read",db:"db02"},
		{role:"read",db:"db03"}
	]
}
)
```

# super user
```
use admin
db.createUser(
{
	user:"superuser",
	pwd:"pwd",
	roles:[
		"root"
	]
}
)
```
