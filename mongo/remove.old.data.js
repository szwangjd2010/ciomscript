/*
 * remove useless data
 */

var DefaultLifetime = 1; // days

var CollectionsLifetime = { // days
	"ip_info_count": 14,
	"config": 30,
	"time_curve": 30,
	"time_percent": -1
};

var Timestamp = getMidnightTimestamp();

function getMidnightTimestamp() {
	var timestamp = (new ObjectId()).getTimestamp().getTime() / 1000;
	return timestamp - timestamp % (24 * 3600);
}

function getBreakpoint(cname) {
	var lifetime = CollectionsLifetime.hasOwnProperty(cname) ? CollectionsLifetime[cname] : DefaultLifetime;
	var breakpointMicrosec = Timestamp - lifetime * 24 * 3600;

	return {
		"microsec": breakpointMicrosec,
		// var objIdMax = ObjectId(Math.floor((new Date('2011/10/10'))/1000).toString(16) + "0000000000000000")
		"objectId": ObjectId(breakpointMicrosec.toString(16) + "0000000000000000")
	};
}

function cleanCollection(c, breakpoint) {
	print(cname + " ... ");
	if (breakpoint.microsec > Timestamp) {
		print("ignored");
		return;
	}

    var queryJson = {
        "$or": [
	        {
	        	"_id" : {
	            	"$lt" : breakpoint.microsec
	        	}
	    	},
	       	{
	       		"_id" : {
	            	"$lt" : breakpoint.objectId
	        	}
	        }
        ]
    };
    var cnt = c.count(queryJson);
    c.remove(queryJson);
	print(cnt + " records cleaned");
}

(function main() {
	if (typeof Database == "undefined") {
		print("no specified database!");
		return;
	}

    print("-----------------------------------------------");
    print(new Date() + ",  begin to clean:");

    var db = connect("localhost:27017/" + Database);
    var cnames = db.getCollectionNames();
    
    for (var i = 0; i < cnames.length; i++) {
        cname = cnames[i];
        if (cname === "system.indexes") {
            continue;
        }
        cleanCollection(db.getCollection(cname), getBreakpoint(cname));
    }

    print("finished!");
})();
