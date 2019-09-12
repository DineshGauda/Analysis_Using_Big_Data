businessData = LOAD 'gs://pda-yelp-bucket/input/business/' using PigStorage(',') AS
(business_id:chararray, business_name:chararray, address:chararray, city:chararray,
state:chararray, latitude:double, longitude:double, stars:double, review_count:int,
is_open:int, categories:chararray);

filterlatlong = FILTER businessData BY latitude < 43.22145313 AND longitude < -89.21487592 AND latitude > 42.93172719 AND longitude > -89.61009908;

groupcategory = GROUP filterlatlong BY categories;

result = FOREACH groupcategory GENERATE FLATTEN(group) as (categories), AVG(filterlatlong.stars) as st;

STORE result INTO 'gs://pda-yelp-bucket/output/pigTask2/output' USING PigStorage(',','-schema');
