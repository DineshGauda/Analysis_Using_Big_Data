import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map.Entry;
import java.util.TreeMap;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.Mapper.Context;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;


	public class TopTenRatedBusiness {

		/*
		 BusinessRatingMapper parses review.csv file and emits business name and respective rating
		 */
		public static class BusinessRatingMapper extends Mapper<LongWritable, Text, Text, FloatWritable> {
			/*
			 * Map function that emits a business name as a key and rating as a value
			 */
			@Override
			protected void map(LongWritable key, Text value, Context context)throws IOException, InterruptedException {

				String reviews[] = value.toString().split(",");
				/*
				 * reviews[9] gives business name and reviews[3] gives business rating
				 */
				context.write(new Text(reviews[9]), new FloatWritable(Float.parseFloat(reviews[3])));

			}
		} 
		
		/*
		 * Class TopRatedBusinessReducer emits top 10 business id with their average rating
		 */
		static TreeMap<Float, List<Text>> reviewID = new TreeMap<Float, List<Text>>(Collections.reverseOrder());

		public static class BusinessRatingReducer extends Reducer<Text, FloatWritable, Text, FloatWritable> {

			/*
			 * Reduce function
			 */
			public void reduce(Text key, Iterable<FloatWritable> values, Context context)throws IOException, InterruptedException {
				float sumOfRatings =  0;
				int countOfRatings = 0;
				for (FloatWritable value : values) {
					sumOfRatings += value.get();
					countOfRatings++; 
				}
				
				Float averageRating = sumOfRatings / countOfRatings;
				
				if (reviewID.containsKey(averageRating)) {
					reviewID.get(averageRating).add(new Text(key.toString()));
				} else {
					List<Text> businessIDList = new ArrayList<Text>();
					businessIDList.add(new Text(key.toString()));
					
					/*
					 * Putting average rating and corresponding business Name
					 */
					reviewID.put(averageRating, businessIDList);
				}
			}
		

			@Override
			protected void cleanup(Reducer<Text, FloatWritable, Text, FloatWritable>.Context context)throws IOException, InterruptedException {
				
				int count=0;
				for(Entry<Float, List<Text>> entry : reviewID.entrySet()) {
					if(count > 10){
						break;
					}
					 
			     FloatWritable result=new FloatWritable();
			     result.set(entry.getKey());
			     
			     for (int i = 0; i <entry.getValue().size(); i++) {
					  if (count >= 10) {
							break;
					  }
					   context.write(new Text(entry.getValue().get(i).toString()), result);
					   count++;
				  }
			     
				}  
		
			}
		}
				
			/*
			 * Driver Program
			 */
			
			public static void main(String[] args) throws IOException,ClassNotFoundException, InterruptedException, NoSuchMethodException {
				
				Configuration conf = new Configuration();
				String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
				if (otherArgs.length != 2) {
					System.err.println("Usage: TopTenRatedBusiness <in> <out>");
					System.exit(2);
				
				}
				
				Job job = new Job(conf, "TopTenRatedBusiness");
				job.setJarByClass(TopTenRatedBusiness.class);
			
				job.setMapperClass(BusinessRatingMapper.class);
				job.setMapOutputKeyClass(Text.class);
				job.setMapOutputValueClass(FloatWritable.class);
			
				job.setReducerClass(BusinessRatingReducer.class);
				job.setOutputKeyClass(Text.class);
				job.setOutputValueClass(FloatWritable.class);
			
				FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
				FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
				System.exit(job.waitForCompletion(true) ? 0 : 1);

		}
	
}
