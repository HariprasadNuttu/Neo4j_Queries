require 'rest-client'
require 'yaml'
$neo4j_urls = YAML.load_file('config/neo4j.yml')
$neo4j_urls = $neo4j_urls[Rails.env]
module Neo4jModule
    URL = "#{$neo4j_urls['url']}/db/data/cypher"
    def Neo4jModule.get(params)
            begin
            response = RestClient.get "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
            rescue => e
              puts "#{e.response}"
            end
            response
        end

        def Neo4jModule.post(params)
            puts "#{params}"
            begin
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
          rescue => e
            puts "#{e.response}"
          end
            # puts "============Response#{response}"
            response
        end

        def Neo4jModule.build_node(params)
            begin
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
          rescue => e
            puts "#{e.response}"
          end
            response
        end
        def Neo4jModule.build_relationship(relationship_array)
                relationship_array.each do |params|
                  begin
                    response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
                    puts "#{params}"
                  rescue => e
                    puts "#{e.response}"
                  end
                    # puts "#{response}"
                end
        end
        def Neo4jModule.update_node(params)
          begin
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
          rescue => e
            puts "#{e.response}"
          end
            response
        end

        def Neo4jModule.destroy_node(params)
          begin

            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
          rescue => e
            puts "#{e.response}"
          end
            response
        end

        def Neo4jModule.destory_previous_relations(params)
          begin
            response = RestClient.post "#{Neo4jModule::URL}", {"query":params[:query],"params":params[:params]}.to_json, {:Authorization=>"#{$neo4j_urls['password']}",:content_type =>"application/json"};
          rescue => e
            puts "#{e.response}"
          end
            response
        end

        def Neo4jModule.match_node(params)

        end

end
