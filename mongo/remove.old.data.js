/*
 * remove all old data - 3 days ago
 *
 *
 */

var Data_Lasting_Duration = 3600 * 24 * 3;

function cleanCollection(c, timestamp) {
        print(cname + " - cleaning ... ");
        var cnt = c.count({ _id : { $lt : timestamp } });
        print(cnt + " records");
        c.remove({ _id : { $lt : timestamp } });
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