use 236363myDBdb.createCollection('results')var date = Date()var post={    "Res":1,    "ID1":123456789,    "ID2":123456789,    "Date":date}db.results.insert(post)db.results.find()