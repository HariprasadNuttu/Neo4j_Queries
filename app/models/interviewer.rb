require 'rest-client'
require 'yaml'
require 'csv'
$neo4j_urls = YAML.load_file('config/neo4j.yml')
$neo4j_urls = $neo4j_urls[Rails.env]
class Interviewer < ApplicationRecord
  include Neo4jModule
  # after_create :create_interviewer
  # after_update :update_interviewer
  # after_destroy :destroy_interviewer
  #   searchkick word_start: [:name]
  #   def search_data
  #   {
  #     name: self.name,
  #
  #   }
  # end

  after_create :build_node
  after_update :update_node
  after_destroy :destroy_node


  def build_node
    interviewer_data = interviewer_profile
    build_node = {"query":"create (interviewer:Freelancer { interviewer_data }) RETURN interviewer","params":{"interviewer_data":interviewer_data}}


    Neo4jModule.build_node(build_node)
    Neo4jModule.build_relationship(build_relationship)


  end
  def update_node
      interviewer_data = interviewer_profile

      update_node = {"query":"match  (interviewer:Freelancer {interviewer_id:{interviewer_id}}) set interviewer= {interviewer_data}  RETURN interviewer","params":{"interviewer_data":interviewer_data,"interviewer_id":self.id.to_i}}
      delete_node_relations = {"query":"MATCH (n:Freelancer {interviewer_id:{interviewer_id}})-[r]-(s) detach delete r" ,"params":{"interviewer_id":self.id.to_i}}
      Neo4jModule.destory_previous_relations(delete_node_relations)
      Neo4jModule.update_node(update_node)
      Neo4jModule.build_relationship(build_relationship)
  end

  def destroy_node
    delete_node = {"query":"MATCH (n:Freelancer {interviewer_id:{interviewer_id}})-[r]-(s) detach delete n" ,"params":{"interviewer_id":self.id.to_i}}
    Neo4jModule.destroy_node(delete_node)
  end

  def self.get_titles(title)

    titles = {"query":"match (title:Title) where toLower(title.name) =~{name} return title.name LIMIT 25" ,"params":{"name":"(?i).*"+title.downcase+".*"}}
    title_response = Neo4jModule.post(titles)
    response = JSON.parse(title_response.body)["data"].collect{|object| object[0]}
    response
  end

  def self.get_skills(name)
    skills = {"query":"match (skill:Skill) where toLower(skill.name) =~{name} return skill.name LIMIT 25" ,"params":{"name":"(?i).*"+name.downcase+".*"}}
    skills_response = Neo4jModule.post(skills)
    response = JSON.parse(skills_response.body)["data"].collect{|object| object[0]}
    response
  end

  def self.match_interviewers(params)
    puts "#{params}"
   puts "#{params[:total_yrs_of_exp].to_i}"
    # if params[:keyword] && params[:level]
    #   puts "Both are satisified"
    #   self.search_with_skill_and_level(params)
    # elsif params[:keyword]
    #   puts "Skill set"
    #   self.search_with_skill(params)
    # elsif params[:level]
    #   puts "Only level"
    #   self.search_with_level(params)
    # end
    # keyword = params[:keyword] ? 'UNWIND {skills_list} as skill_name' : ''
    # search_with_skill_ignore_case =  params[:keyword] ? "where skill.name =~ ('(?i)'+ skill_name)" : ''
    keyword = params[:keyword] ? 'with {skills_list} as data' : ''
    # search_with_skill_ignore_case =  params[:keyword] ? " where TOLOWER(skill.name) IN data" : ''
    level = params[:level] ? '{level:{level}}': '';
    language = params[:language] ? '{name:{language}}' : '';
    domain = params[:domain] ? '{name:{domain}}' : '';
    proficiency = params[:proficiency] ? '{Proficiency:{proficiency}}': '';
    location = params[:location] ? '{name:{location}}': ''
    # yrs_of_exp = params[:total_yrs_of_exp] ? '{total_yrs_of_exp:{total_yrs_of_exp}}': ''
    search_with_skill_ignore_case=''
  exp =   params[:total_yrs_of_exp].to_i
  if(params[:keyword] && params[:total_yrs_of_exp])
      yrs_of_exp = '';
      search_with_skill_ignore_case = " where TOLOWER(skill.name) IN data AND interviewer.total_yrs_of_exp >= {total_yrs_of_exp} ";
  elsif(params[:keyword])
    search_with_skill_ignore_case = " where TOLOWER(skill.name) IN data" ;
    yrs_of_exp =''
  elsif(params[:total_yrs_of_exp])
    # yrs_of_exp = '{total_yrs_of_exp:{total_yrs_of_exp}}';
    search_with_skill_ignore_case = " where interviewer.total_yrs_of_exp >= {total_yrs_of_exp}" ;
  end

#   skill_level = {"query":"UNWIND {skills_list} as skill_name match(skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains"+domain+") where skill.name =~ ('(?i)'+ skill_name)  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":level,"language":language,"domain":domain,"proficiency":proficiency}}
# puts "#{skill_level}"
      # skill_level = {"query":"UNWIND {skills_list} as skill_name match (skill:Skill)<-[:Has_experience"+level+"]- (interviewer:Freelancer"+yrs_of_exp+")-[:Has_Knowledge]->(d:Domains"+domain+") match(l:Languages"+language+")<-[:Understands"+proficiency+"]-(interviewer)-[:Has_Location]->(location:Location"+location+") where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":params[:level] ? params[:level] :'',"domain":params[:domain] ? params[:domain] :'',"proficiency":params[:proficiency] ? params[:proficiency] :'',"language":params[:language] ? params[:language] :'',"location":params[:location] ? params[:location] :'',"total_yrs_of_exp": params[:total_yrs_of_exp] ? exp :''}}
      #
      # skill_level = {"query":"match (interviewer:Freelancer)-[r:Has_experience]->(s:Skill{name:'Java'}) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":params[:level] ? params[:level] :'',"domain":params[:domain] ? params[:domain] :'',"proficiency":params[:proficiency] ? params[:proficiency] :'',"language":params[:language] ? params[:language] :'',"location":params[:location] ? params[:location] :'',"total_yrs_of_exp": params[:total_yrs_of_exp] ? exp :''}}

      # skill_level = {"query":""+keyword+" match (skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer"+yrs_of_exp+")-[:Has_Knowledge]-(domain:Domains"+domain+"),(language:Languages"+language+")<-[:Understands"+proficiency+"]-(interviewer)-[:Has_Location]->(location:Location"+location+") "+search_with_skill_ignore_case+" with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/).map {|key| key.downcase} : ".*" ,"level":params[:level] ? params[:level] :'',"domain":params[:domain] ? params[:domain] :'',"proficiency":params[:proficiency] ? params[:proficiency] :'',"language":params[:language] ? params[:language] :'',"location":params[:location] ? params[:location] :'',"total_yrs_of_exp": params[:total_yrs_of_exp] ? exp :''}}
        skill_level = {"query":""+keyword+" match (skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer)-[:Has_Knowledge]-(domain:Domains"+domain+"),(language:Languages"+language+")<-[:Understands"+proficiency+"]-(interviewer)-[:Has_Location]->(location:Location"+location+") "+search_with_skill_ignore_case+" with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/).map {|key| key.downcase} : ".*" ,"level":params[:level] ? params[:level] :'',"domain":params[:domain] ? params[:domain] :'',"proficiency":params[:proficiency] ? params[:proficiency] :'',"language":params[:language] ? params[:language] :'',"location":params[:location] ? params[:location] :'',"total_yrs_of_exp": params[:total_yrs_of_exp] ? exp :''}}
      puts "====================="
puts "#{skill_level}"
puts "=========================="
    response = Neo4jModule.post(skill_level)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end


  def self.domain_based(params)
    puts "#{params}"
    # if params[:domain] && params[:language]
    #   puts "Both are satisified"
    #   self.search_with_domain_and_language(params)
    # elsif params[:domain]
    #   puts "Domain"
    #   self.search_with_domain(params)
    # elsif params[:language]
    #   puts "Only level"
    #   self.search_with_language(params)
    # end
    domain = params[:domain] ? '{name:{domain_name}}' : ''
    language = params[:language] ? '{name:{language}}' : ''
    domain_language = {"query":"match p = (domain:Domains"+domain+")<-[r:Has_Knowledge]-(interviewer:Freelancer)-[:Understands]->(language:Languages"+language+") with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"domain_name":params[:domain],"language":params[:language]}}
    response = Neo4jModule.post(domain_language)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}


  end
  def self.search_with_skill_and_level(params)
    puts "search_with_skill_and_level"

    skill_level = {"query":"UNWIND {skills_list} as skill_name match(interviewer:Freelancer)-[:Has_experience{level:{level}}]->(skill:Skill) where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword].split(/, |,/),"level":params[:level]}}
    response = Neo4jModule.post(skill_level)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end
  def self.search_with_skill(params)
    puts "search_with_skill"

    skills = {"query":"UNWIND {skills_list} as skill_name match(interviewer:Freelancer)-[:Has_experience]->(skill:Skill) where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword].split(/, |,/)}}
    response = Neo4jModule.post(skills)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
  end
  def self.search_with_level(params)
    puts "search_with_level"
    level = {"query":"match(interviewer:Freelancer)-[:Has_experience{level:{level}}]->(skill:Skill)  WITH DISTINCT interviewer as interviewer_data RETURN  {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"level":params[:level]}}
    response = Neo4jModule.post(level)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end

  def self.search_with_language(params)
    puts "search_with_language"
    language = {"query":"MATCH p=(interviewer:Freelancer)-[r:Understands]->(language:Languages) where language.name =~ ('(?i)'+ {language})  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"language":params[:language]}}
    response = Neo4jModule.post(language)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end

  def self.search_with_domain(params)
    puts "search_with_domain"
    domain = {"query":"MATCH p=(interviewer:Freelancer)-[r:Has_Knowledge]->(domain:Domains) where domain.name =~ ('(?i)'+ {domain})  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"domain":params[:domain]}}
    response = Neo4jModule.post(domain)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end
  def self.search_with_domain_and_language(params)
    puts "search_with_domain_and_language"
    domain_language = {"query":"match p = (domain:Domains{name:{domain_name}})<-[r:Has_Knowledge]-(interviewer:Freelancer)-[:Understands]->(language:Languages{name:{language}}) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"domain_name":params[:domain],"language":params[:language]}}
    response = Neo4jModule.post(domain_language)
    JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}

  end

  def interviewer_profile
    interviewer_data={"name":self.name,"email":self.email,title:self.title,skills:self.skills.split(/, |,/) , languages:self.languages.split(/, |,/) , interviewer_id:self.id.to_i,skill_set:self.skill_set.split(/, |,/), languages_set:self.languages_set.split(/, |,/),domain: domain ? self.domain.split(/, |,/) : nil ,location:self.location,total_yrs_of_exp:self.total_yrs_of_exp.to_i}
    # location,total_yrs_of_exp
    interviewer_data

  end

  def build_relationship

    has_experience = {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1],is_certified:split(skill_name,'-')[2]}]->(skill))) return interviewer,skill","params":{"id":self.id.to_i}}

    understands = {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(language:Languages) where language.name IN interviewer.languages_set foreach (language_name IN interviewer.languages | foreach (k in (case when split(language_name,'-')[0]=language.name  then [1] else [] end) | merge (interviewer)-[:Understands {Proficiency:split(language_name,'-')[1]}]->(language))) return interviewer,language","params":{"id":self.id.to_i}}

    has_knowledge = {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(domain:Domains) where domain.name IN interviewer.domain foreach (object IN interviewer.domain |
    foreach (k in (case when split(object,'-')[0]=domain.name  then [1] else [] end) | merge (interviewer)-[:Has_Knowledge]->(domain))) return interviewer,domain","params":{"id":self.id.to_i}}

    worked_as = {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(title:Title) where title.name = interviewer.title merge (interviewer)-[:Worked_As]->(title) return interviewer,title","params":{"id":self.id.to_i}}

    result = {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(location:Location) where location.name = interviewer.location  return interviewer,location","params":{"id":self.id.to_i}}
    puts "#{result}"

    has_location = {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(location:Location) where location.name = interviewer.location merge (interviewer)-[:Has_Location]->(location) return interviewer,location","params":{"id":self.id.to_i}}
puts "#{has_location}"
    relationship = [has_experience,understands,has_knowledge,worked_as,has_location,result]

    relationship

  end



  def self.import_data
    # CSV.foreach("new_interviewers.csv",:headers => true) do |row|
    #   interviewer = Interviewer.new name:row[0],email:row[1],title:row[3],skills:row[4],languages_set:row[7],skill_set:row[5],languages:row[6],domain:row[2],location:"India",total_yrs_of_exp:5
    #   if interviewer.save
    #     puts "#{interviewer}"
    #   end
    # end
    CSV.foreach("graph-interviewers.csv",:headers => true) do |row|
      # puts "#{row[0]} ================#{row[8]}"
      unless ["harnadha@gmail.com","harinam007@yahoo.com","athiruml@gmail.com"].include? row[1]

        interviewer=   Interviewer.create(name: row[0], email: row[1], skill_set:row[2] , title: row[3], languages:row[4], expertise: row[5], languages_set: row[6] , skills: row[7], domain: row[8], location: row[9], total_yrs_of_exp: row[10] )
        puts "#{interviewer}"
      end
    end



  end

  def sample
    puts "search_with_domain_and_language"
    has_experience = {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1]}]->(skill))) return interviewer,skill","params":{"id":self.id.to_i}}
      response = Neo4jModule.post(has_experience)
      puts "#{response}"
  end
















































=begin



  def create_interviewer
    puts "================== Create Node Start================"
    puts " #{self.to_json}"
    interviewer_data = interviewer_profile

    interviewer = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"CREATE (interviewer:Freelancer { name }) RETURN interviewer","params":{"name":interviewer_data}}.to_json, :content_type =>"application/json";

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
    interviewer_data={"name":self.name,"email":self.email,title:self.title,skills:self.skills.split(","),languages:self.languages.split(","),interviewer_id:self.id.to_i,skill_set:self.skill_set.split(','),languages_set:self.languages_set.split(","),domain: domain ? self.domain.split(",") : nil }
    interviewer_data
  end

  def mapping_relationxship
    puts "==============Has Experince Start ============"
    has_experience = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(skill:Skill) where skill.name IN interviewer.skill_set foreach (skill_name IN interviewer.skills | foreach (k in (case when split(skill_name,'-')[0]=skill.name  then [1] else [] end) | merge (interviewer)-[:Has_experience {level:split(skill_name,'-')[1]}]->(skill))) return interviewer,skill" ,"params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";

    puts "#{has_experience}"
    puts "==============Has Experince  End============"

    puts "=============Understands Start======="
    understands = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (interviewer:Freelancer{interviewer_id:{id}}),(language:Languages) where language.name IN interviewer.languages_set foreach (language_name IN interviewer.languages | foreach (k in (case when split(language_name,'-')[0]=language.name  then [1] else [] end) | merge (interviewer)-[:Understands {Proficiency:split(language_name,'-')[1]}]->(language))) return interviewer,language","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{understands}"
    puts "=============Understands End=========="

    puts "=============Has Knowledge Start======="
    has_knowledge = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(domain:Domains) where domain.name IN interviewer.domain foreach (object IN interviewer.domain |
    foreach (k in (case when split(object,'-')[0]=domain.name  then [1] else [] end) | merge (interviewer)-[:Has_Knowledge]->(domain))) return interviewer,domain","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{has_knowledge}"
    puts "=============Has Knowledge End=========="

    puts "=============Worked As  Start======="
    worked_as = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (interviewer:Freelancer {interviewer_id:{id}}),(title:Title) where title.name = interviewer.title merge (interviewer)-[:Worked_As]->(title) return interviewer,title","params":{"id":self.id.to_i}}.to_json, :content_type =>"application/json";
    puts "#{worked_as}"
    puts "=============Worked As End=========="

  end
  def destroy_interviewer
    destory_interviewer = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (interviewer:Freelancer {interviewer_id:{id}}) detach delete interviewer","params":{"id":self.id.to_i}}.to_json,:content_type =>"application/json";
    puts "#{destory_interviewer}"
  end
  def self.get_titles(title)
    titles = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (title:Title) where toLower(title.name) =~{name} return title.name LIMIT 25","params":{"name":"(?i).*"+title.downcase+".*"}}.to_json, :content_type =>"application/json";

    response = JSON.parse(titles.body)["data"].collect{|object| object[0]}
    response
  end

  def self.get_skills(name)
    titles = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match (skill:Skill) where toLower(skill.name) =~{name} return skill.name LIMIT 25" ,"params":{"name":"(?i).*"+name.downcase+".*"}}.to_json, :content_type =>"application/json";

    response = JSON.parse(titles.body)["data"].collect{|object| object[0]}
    response
  end
  def self.match_interviewers(params)
    puts "#{params}"
    if params[:keyword] && params[:level]
      puts "Both are satisified"
      self.search_with_skill_and_level(params)
    elsif params[:keyword]
      puts "Skill set"
      self.search_with_skill(params)
    elsif params[:level]
      puts "Only level"
      self.search_with_level(params)
    end

  end


  def self.domain_based(params)
    puts "#{params}"
    if params[:domain] && params[:language]
      puts "Both are satisified"
      self.search_with_domain_and_language(params)
    elsif params[:domain]
      puts "Domain"
      self.search_with_domain(params)
    elsif params[:language]
      puts "Only level"
      self.search_with_language(params)
    end

  end



  def self.search_with_skill_and_level(params)
    puts "search_with_skill_and_level"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"UNWIND {skills_list} as skill_name match(interviewer:Freelancer)-[:Has_experience{level:{level}}]->(skill:Skill) where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name ","params":{"skills_list":params[:keyword].split(/, |,/),"level":params[:level]}}.to_json,:content_type =>"application/json";

    # interviewers_data = JSON.parse(response.body)["data"]
    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end
  def self.search_with_skill(params)
    puts "search_with_skill"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"UNWIND {skills_list} as skill_name match(interviewer:Freelancer)-[:Has_experience]->(skill:Skill) where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name ","params":{"skills_list":params[:keyword].split(/, |,/)}}.to_json,:content_type =>"application/json";

    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end
  def self.search_with_level(params)
    puts "search_with_level"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match(interviewer:Freelancer)-[:Has_experience{level:{level}}]->(skill:Skill)  WITH DISTINCT interviewer as interviewer_data RETURN  {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name ","params":{"level":params[:level]}}.to_json,:content_type =>"application/json";

    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end

  def self.search_with_language(params)
    puts "search_with_language"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"MATCH p=(interviewer:Freelancer)-[r:Understands]->(language:Languages) where language.name =~ ('(?i)'+ {language})  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name ","params":{"language":params[:language]}}.to_json,:content_type =>"application/json";

    # interviewers_data = JSON.parse(response.body)["data"]
    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end

  def self.search_with_domain(params)
    puts "search_wit:"UNWIND {skills_list} as skill_name match(skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains"+domain+") where skill.name =~ ('(?i)'+ skill_name)  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":level,"language":language,"domain":domain,"proficiency":proficiency}}
# puts "#{skill_level}"h_domain"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"MATCH p=(interviewer:Freelancer)-[r:Has_Knowledge]->(domain:Domains) where domain.name =~ ('(?i)'+ {domain})  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name ","params":{"domain":params[:domain]}}.to_json,:content_type =>"application/json";

    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end
  def self.search_with_domain_and_language(params)
    puts "search_with_domain_and_language"
    response = RestClient.post "#{$neo4j_urls['url']}/db/data/cypher", {"query":"match p = (domain:Domains{name:{domain_name}})<-[r:Has_Knowledge]-(interviewer:Freelancer)-[:Understands]->(language:Languages{name:{language}}) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data:"UNWIND {skills_list} as skill_name match(skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains"+domain+") where skill.name =~ ('(?i)'+ skill_name)  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":level,"language":language,"domain":domain,"proficiency":proficiency}}
# puts "#{skill_level}".name ","params":{"domain_name":params[:domain],"language":params[:language]}}.to_json,
    :content_type =>"application/json";

    interviewers= JSON.parse(response.body)["data"].collect{|object| object[0]["interviewers"]}
    puts "#{interviewers}"
    interviewers
  end
  def self.import_data
    CSV.foreach("new_interviewers.csv",:headers => true) do |row|
      interviewer = Interviewer.new name:row[0],email:row[1],title:row[3],skills:row[4],languages_set:row[7],skill_set:row[5],languages:row[6],domain:row[2]
      if interviewer.save
        puts "#{interviewer}"
      end
    end

  end

=end
end




# match(skill:Skill{name:"Java"})<-[:Has_experience{level:"Proficient"}]-(interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains{name:"Accommodation"}) match(interviewer)-[:Understands{Proficiency:"Native"}]->(l:Languages{name:"English"}) return interviewer



# skill_level = {"query":"UNWIND {skills_list} as skill_name match(skill:Skill)<-[:Has_experience"+level+"]-(interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains"+domain+") where skill.name =~ ('(?i)'+ skill_name)  with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":level,"language":language,"domain":domain,"proficiency":proficiency}}
# puts "#{skill_level}"





# matched query
# skill_level = {"query":"UNWIND {skills_list} as skill_name match (skill:Skill)<-[:Has_experience"+level+"]- (interviewer:Freelancer)-[:Has_Knowledge]->(d:Domains"+domain+") where skill.name =~ ('(?i)'+ skill_name) with DISTINCT interviewer as interviewer_data  RETURN {interviewers:interviewer_data{.*}} as object ORDER BY interviewer_data.name" ,"params":{"skills_list":params[:keyword] ? params[:keyword].split(/, |,/) : ".*" ,"level":params[:level] ? params[:level] :'',"domain":params[:domain] ? params[:domain] :''}}
#



# Interviewer.create(name: "Hariprasad Nuttu", email: "hariprasadnuttu@gmail.com", skill_set:"Java","Ruby" , title: "Java Developer", languages:"English-Fluent","Mandarin-Native", expertise: nil, languages_set: "English","Mandarin" , skills: "Java-Competent","Ruby-Expert", domain: "Accommodation", location: "India", total_yrs_of_exp: 3 )
