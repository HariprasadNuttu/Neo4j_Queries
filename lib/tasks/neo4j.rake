require 'rest-client'
namespace :neo4j do
  desc "TODO"
  task create_nodes: :environment do
    # interviewer_node = RestClient.post 'http://172.16.19.169:8500',{
      # {"query" : "CREATE (n:Person { name : {name} }) RETURN n","params" : {"name" : "Andres"}}
    # }
    # ,
    # {
    #   "query" : "Create constraint on(f:Freelancer) Assert f.interviewer_id is unique",
    #   "params" : {
    #   }
    #
    # }
    # Create index on:Freelancer(skill_set)

    response = RestClient.post "http://172.16.19.169:8500/db/data/cypher", {"query":"CREATE (n:Person { name : {name} }) RETURN n","params":{"name":"Andres"}}.to_json, :content_type =>"application/json";
    puts "#{response}"
  end

end
