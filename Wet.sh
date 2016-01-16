use 236363myDB//1db.createCollection('results')var date = Date()var post={    "Res":1,    "ID1":123456789,    "ID2":123456789,    "Date":date}db.results.insert(post)//2db.getCollection('documents').find({}).forEach(function(doc){    var values = doc.query_text.split(" ");    sum=0;    for (i = 0; i < values.length; i++)    {        var count = doc.content.split(' ' + values[i] + ' ').length-1;        sum=sum+count;    }    doc.rank=sum;    db.documents.save(doc);});var documents=db.getCollection('documents').find({}).sort({    'query_num':1,    'rank':-1,    first_name:1,    last_name:1})var finalResult={    "Res":2,    "documents":documents.toArray()}db.results.insert(finalResult);

//3
var res = db.results.aggregate(
{
    $unwind : "$documents"
},
{
    $match : {Res : 2}
},
{
    $sort : {"documents.rank" : -1, "documents.query_num" : 1}
},
{
    $limit : 2
},
{
   $project: { "_id" : 0 , "query_text" : "$documents.query_text" } 
}
).result[0]

res.Res = 3
db.results.insert(res)
