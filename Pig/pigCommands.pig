businessData = LOAD 'gs://pda-yelp-bucket/input/business/' using PigStorage(',') AS
(business_id:chararray, business_name:chararray, address:chararray, city:chararray,
state:chararray, latitude:double, longitude:double, stars:double, review_count:int,
is_open:int, categories:chararray);

groupcitycat = GROUP businessData BY (city,categories);

avgstars = FOREACH groupcitycat GENERATE FLATTEN(group) as (city,categories), AVG(businessData.stars) as st;

result = RANK avgstars by categories ASC, st DESC;

STORE result INTO 'gs://pda-yelp-bucket/output/pig/output' USING PigStorage(',','-schema');