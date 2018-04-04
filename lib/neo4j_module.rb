require 'rest-client'
require 'yaml'
$neo4j_urls = YAML.load_file('config/neo4j.yml')
$neo4j_urls = $neo4j_urls[Rails.env]
module Neo4jModule
    URL = "#{$neo4j_urls['url']}/db/data/cypher"
    def Neo4jModule.get(params)
            response = RestClient.get "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            response
        end

        def Neo4jModule.post(params)
            puts "#{params}"
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            # puts "============Response#{response}"
            response
        end

        def Neo4jModule.build_node(params)
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            response
        end
        def Neo4jModule.build_relationship(relationship_array)
                relationship_array.each do |params|
                    response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
                    puts "#{params}"
                    # puts "#{response}"
                end
        end
        def Neo4jModule.update_node(params)
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            response
        end

        def Neo4jModule.destroy_node(params)
          puts params
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            puts "#{response}"
            response
        end

        def Neo4jModule.destory_previous_relations(params)
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, :content_type =>"application/json";
            response
        end

        def Neo4jModule.match_node(params)

        end

end
