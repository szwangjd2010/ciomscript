/*
 * remove all old data - 3 days ago
 *
 *
 */

var Data_Lasting_Duration = 3600 * 24 * 3;

function cleanCollection(c, before) {
        var cnt = c.count({ _id : { $lt : before } });
        print(cnt + " records");
        c.remove({ _id : { $lt : before } });
}

(function main() {
        print("-----------------------------------------------");
        print(new Date());

        var db = connect("localhost:27017/datav_dashboard");
        var cnames = db.getCollectionNames();
        var timestamp = (new ObjectId()).getTimestamp().getTime() / 1000;
        var before = timestamp - Data_Lasting_Duration;
        for (var i = 0; i < cnames.length; i++) {
                cname = cnames[i];
                if (cname === "system.indexes") {
                        continue;
                }
                print(cname + " - cleaning ... ");
                cleanCollection(db.getCollection(cname), before);
                print("done")
        }

        print("finished!");
        print("");
})();