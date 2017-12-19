require 'rest-client'
namespace :neo4j do
  desc "TODO"
  task create_nodes: :environment do

    puts "=============Create Interviewer Node Start=========="
    create_interviewer = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create constraint on(interviewer:Freelancer) Assert interviewer.interviewer_id is unique"}.to_json, :content_type =>"application/json";
    create_interviewer_index = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create index on:Freelancer(skill_set)"}.to_json, :content_type =>"application/json";

    puts "#{create_interviewer}"
    puts "#{create_interviewer_index}"
    puts "=============Create Interviewer Node End=========="

    puts "=============Create Skill Node Start=========="
    create_skill = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create constraint on(skill:Skill) Assert skill.name is unique"}.to_json, :content_type =>"application/json";
    puts "#{create_skill}"
    puts "=============Create Skill Node End=========="


    puts "=============Create Languages Node Start=========="
    create_language = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create constraint on(language:Languages) Assert language.name is unique "}.to_json, :content_type =>"application/json";
    puts "#{create_language}"
    puts "=============Create Language Node End=========="

    puts "=============Create Domain Node Start=========="
    create_domain = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create constraint on(domain:Domains) Assert domain.name is unique"}.to_json, :content_type =>"application/json";
    puts "#{create_domain}"
    puts "=============Create domain Node End=========="

    puts "=============Create Title Node Start=========="
    create_title = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"Create constraint on(title:Title) Assert title.name is unique"}.to_json, :content_type =>"application/json";

    puts "#{create_title}"
    puts "=============Create Title Node End=========="

  end

end
