/*
 * remove all old data - 3 days ago
 *
 *
 */

var Data_Lasting_Duration = 3600 * 24 * 3;

function cleanCollection(c, timestamp) {
        var queryJson = {
                _id : {
                        $lt : timestamp 
                } 
        };
        
        var cnt = c.count(queryJson);
        print(cname + " - cleaning ... ");
        print(cnt + " records");
        c.remove(queryJson);
        print("done")
}

(function main() {
        print("-----------------------------------------------");
        print(new Date());

        var db = connect("localhost:27017/datav_dashboard");
        var cnames = db.getCollectionNames();
        var timestampClean = (new ObjectId()).getTimestamp().getTime() / 1000 - Data_Lasting_Duration;
        for (var i = 0; i < cnames.length; i++) {
                cname = cnames[i];
                if (cname === "system.indexes") {
                        continue;
                }
                cleanCollection(db.getCollection(cname), timestampClean);
        }

        print("finished!");
        print("");
})();