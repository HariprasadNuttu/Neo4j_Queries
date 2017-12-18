require 'rest-client'
class Interviewer < ApplicationRecord
  after_create :create_interviewer
  after_update :update_interviewer

  def self.create_interviewer()
    # data = RestClient.get 'http://172.16.19.169:8500'
    # return "Hello world"
    # data['bolt']
    # response = RestClient.post "http://172.16.19.169:8500/db/data/cypher", {"query":"CREATE (n:Person { name : {name} }) RETURN n","params":{"name":"Andres"}}.to_json, :content_type =>"application/json";
    # puts "#{response}"

    #   RestClient.post('http://172.16.19.169:8500/db/data/cypher', {"query":"CREATE (n:Person { name : {name} }) RETURN n","params":{"name":"Andres"}}.to_json) { |response, request, result|
    #     puts "#{response}"
    #     puts "#{request}"
    #     puts "#{result}"
    # case response.code
    # when 301, 302, 307
    #   response.follow_redirection
    # else
    #   response.return!
    # end

    dup =  {"name":"Hariprasad nUttu", "email":"hariprasadnuttu@gmail.com"}

    response = RestClient.post "http://172.16.19.200:8500/db/data/cypher", {"query":"CREATE (n:Person { name }) RETURN n","params":{"name":dup}}.to_json, :content_type =>"application/json";


  end
  # def self.update_interviewer(skill)
  #
  # end
  # private
  def create_interviewer
    puts "================== Create Node Start================"
    puts " #{self.to_json}"
    interviewer_data = interviewer_profile

    interviewer = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"CREATE (interviewer:Freelancer { name }) RETURN interviewer","params":{"name":interviewer_data}}.to_json, :content_type =>"application/json";

    puts "#{interviewer}"
    puts "================== Create Node End================"
=begin
      puts " Mapping Relationships"
      puts "==============Has Experince Start ============"
      has_experience = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1]}]->(skill))) return interviewer,skill" ,"params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";

      puts "#{has_experience}"
      puts "==============Has Experince  End============"

      puts "=============Understands Start======="
      understands = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(language:Languages) where language.name IN interviewer.languages_set foreach (language_name IN interviewer.languages | foreach (k in (case when split(language_name,'-')[0]=language.name  then [1] else [] end) | merge (interviewer)-[:Understands {Proficiency:split(language_name,'-')[1]}]->(language))) return interviewer,language","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
      puts "#{understands}"
      puts "=============Understands End=========="
=end
    mapping_relationxship
    interviewer
  end
  def update_interviewer
    puts "================== Update Node Start================"
    puts " #{self.to_json}"
    interviewer_data = interviewer_profile

    response = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"UNWIND { interviewer_data } AS interviewer_data match  (interviewer:Freelancer {interviewer_id:{interviewer_id}}) set interviewer= interviewer_data  RETURN interviewer","params":{"interviewer_id":self.id.to_i,"interviewer_data":interviewer_data}}.to_json, :content_type =>"application/json";

    puts "#{response}"
    puts "================== Update Node End================"
    #
    #     puts " Update Relationships"
    #     puts "==============Has Experince Start ============"
    #     has_experience = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1]}]->(skill))) return interviewer,skill" ,"params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    #
    #     puts "#{has_experience}"
    #     puts "==============Has Experince  End============"
    #
    #     puts "=============Understands Start======="
    #     understands = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(language:Languages) where language.name IN interviewer.languages_set foreach (language_name IN interviewer.languages | foreach (k in (case when split(language_name,'-')[0]=language.name  then [1] else [] end) | merge (interviewer)-[:Understands {Proficiency:split(language_name,'-')[1]}]->(language))) return interviewer,language","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    #     puts "#{understands}"
    #     puts "=============Understands End=========="
    mapping_relationxship
    response
  end


  def interviewer_profile
    interviewer_data={"name":self.name,"email":self.email,title:self.title,skills:self.skills.split(","),languages:self.languages.split(","),interviewer_id:self.id.to_i,skill_set:self.skill_set.split(','),languages_set:self.languages_set.split(","),domain:self.expertise.split(",")}
    interviewer_data
  end

  def mapping_relationxship
    puts "==============Has Experince Start ============"
    has_experience = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1]}]->(skill))) return interviewer,skill" ,"params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";

    puts "#{has_experience}"
    puts "==============Has Experince  End============"

    puts "=============Understands Start======="
    understands = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(language:Languages) where language.name IN interviewer.languages_set foreach (language_name IN interviewer.languages | foreach (k in (case when split(language_name,'-')[0]=language.name  then [1] else [] end) | merge (interviewer)-[:Understands {Proficiency:split(language_name,'-')[1]}]->(language))) return interviewer,language","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{understands}"
    puts "=============Understands End=========="

    puts "=============Has Knowledge Start======="
    has_knowledge = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(domain:Domains) where domain.name IN interviewer.domain foreach (object IN interviewer.domain |
	foreach (k in (case when split(object,'-')[0]=domain.name  then [1] else [] end) | merge (interviewer)-[:Has_Knowledge]->(domain))) return interviewer,domain","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{has_knowledge}"
    puts "=============Has Knowledge End=========="

    puts "=============Worked As  Start======="
    worked_as = RestClient.post "http://172.16.19.239:8500/db/data/cypher", {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(title:Title) where title.name = interviewer.title merge (interviewer)-[:Worked_As]->(title) return interviewer,title","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{worked_as}"
    puts "=============Worked As End=========="

  end

end
