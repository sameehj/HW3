//1db.createCollection('results')var date = Date()var post={    "Res":1,    "ID1":308311356,    "ID2":204496004,    "Date":date}db.results.insert(post)//2db.getCollection('documents').find({}).forEach(function(doc){    var values = doc.query_text.split(" ");    sum=0;    for (i = 0; i < values.length; i++)    {        var temp_arr = doc.content.split(" ");        var count = 0;		temp_arr.forEach(function(ele){			if(values[i] == ele){				count = count +1;			}		})        sum=sum+count;    }    doc.rank=sum;    db.documents.save(doc);});var documents=db.getCollection('documents').find({},{_id : 0}).sort({    'query_num':1,    'rank':-1,    first_name:1,    last_name:1})var finalResult={    "Res":2,    "documents":documents.toArray()}db.results.insert(finalResult);

//3
var res = db.results.aggregate({$unwind : "$documents"},{$match : {Res : 2}},{$sort : {"documents.rank" : -1, "documents.query_num" : 1}},{$limit : 1},{$project: { "_id" : 0 , "query_text" : "$documents.query_text" }}).result[0]
res.Res = 3
db.results.insert(res)//4var result_4 = db.documents.aggregate({$sort : {query_num : 1,rank : -1,first_name : 1 , last_name : 1}},{$group : {_id : '$query_num',avg : {$avg : "$rank"},min : {$min : "$rank"},rank : {$max : "$rank"}, content : {$first:"$content"}}},{$sort : {_id:1}}).resultvar res4 = {"Res" : 4}res4.query_statistics = result_4db.results.insert(res4)//5var myDocsCount=db.getCollection('documents').find({ $or: [ { 'last_name': 'Levi' }, { 'date': { $gte : new ISODate("2015-12-12T01:00:00") }} ] }).count()var result5={    'Res':5,    'count':myDocsCount}db.results.insert(result5);
//6var myTemp = db.documents.aggregate({    $sort:{        rank:-1,		first_name:1,		last_name:1        }},{    $group:{        _id:{query_num:'$query_num'},        first_name:{$first:'$first_name'},        last_name:{$first:'$last_name'},        rank:{$first:'$rank'},       }},{    $group:{        _id:{first_name:'$first_name',last_name:'$last_name'},          number_of_top_ranked_documents:{ $sum:1 } }},{    $project:{        _id:0,           first_name:'$_id.first_name',        last_name:'$_id.last_name',        number_of_top_ranked_documents:'$number_of_top_ranked_documents'    }},{    $sort:{        number_of_top_ranked_documents:-1,        first_name:1,        last_name:1    }})db.results.insert({    'Res':6,    'publishers_statistics':myTemp.result})//7db.documents.aggregate({$group:{_id : '$query_num'}}).result.forEach(function(qq){    var query_docs = db.documents.find({ query_num : qq._id }).sort({ rank : -1, first_name : 1, last_name : 1}).toArray();    var max_content = query_docs[0].content.split(" ");    for (i = 0; i < query_docs.length; i++){        var srank=0;        var curr_content = query_docs[i].content.split(" ");        for (j = 0; j < max_content.length; j++){            if(curr_content.indexOf(max_content[j]) != -1){                srank = srank + 1;            }        }        query_docs[i].current_position = i+1;        query_docs[i].sim_rank = srank/curr_content.length;        db.documents.save(query_docs[i])    }    query_docs = db.documents.find({ query_num : qq._id }).sort({ sim_rank : -1, first_name : 1, last_name : 1}).toArray();    for (i = 0; i < query_docs.length; i++)    {        sim_position = i+1;        query_docs[i].rank = 0.8*(query_docs.length-query_docs[i].current_position+1) - 0.2*(query_docs.length-sim_position+1);                db.documents.save(query_docs[i])    }    })db.documents.update({},{$unset: {current_position:1}},{multi: true});db.documents.update({},{$unset: {sim_rank:1}},{multi: true});var documents=db.getCollection('documents').find({},{_id : 0}).sort({    'query_num':1,    'rank':-1,    first_name:1,    last_name:1})var finalResult={    "Res":7,    "diversity_model":documents.toArray()}db.results.insert(finalResult);