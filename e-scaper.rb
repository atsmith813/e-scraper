require 'watir'
require 'csv'
require 'colorize'
require 'pry'
require 'dotenv/load'

@browser = Watir::Browser.new :chrome

@page_number = 1
@page_cap = 51
@columns_on = true

def scrape_site(starting_point = nil)
  begin
    puts "Opening browser...".yellow
    while @page_number <= @page_cap
      @browser.goto("#{ENV['E_COMMERCE_SITE']}#{@page_number}")

      # Grab brands and links
      puts "Grabbing brand links...".yellow
      name_links = []
      @browser.links(class: 'table-cell').each do |tc|
        name_links << {
          "brand" => tc.text,
          "url" => tc.href
        }
      end

      name_links.slice!(0..starting_point) if starting_point
      total_brands = name_links.length
      brands_processed = 1

      puts "Found #{total_brands} brands".green

      check_text = ['VIEW ALL', 'View All']

      # Go to brand page and grab each product
      puts "Grabbing product info...".yellow
      product_count = 0
      name_links.each do |name_link|
        info_count = 0
        brand = name_link["brand"]
        link = name_link["url"]
        current_location = brands_processed.to_i - 2
        puts "Processing #{brands_processed}/#{total_brands} brands on page #{@page_number}...".yellow
        puts "Grabbing products for #{brand}".yellow
        @browser.goto(link)

        product_links = []

        begin
          Watir::Wait.until { @browser.div(class: 'card-content').visible? }
        rescue Watir::Exception::UnknownObjectException
          next
        end

        # Find all categories
        containers = @browser.divs(class: 'slide-row-container')
        unless containers.count == 0
          containers.each do |container|
            link_text = []
            container.divs(class: 'slide-row-header').each do |header|
              header.links.each do |link|
                link_text << link.text
              end
            end

            new_page = link_text & check_text
            if new_page.empty?
              begin
                Watir::Wait.until { @browser.div(class: 'card-content').visible? }
              rescue Watir::Exception::UnknownObjectException
                scrape_site(current_location)
              end
              container.divs(class: 'card-content').each do |card|
                product_links << [brand, card.link.href]
                info_count += 1
              end
            else
              @browser.goto(container.link(class: 'btn-rounded').href)
              begin
                Watir::Wait.until { @browser.div(class: 'card-content').visible? }
              rescue Watir::Exception::UnknownObjectException
                scrape_site(current_location)
              end
              @browser.divs(class: 'card-content').each do |card|
                product_links << [brand, card.link.href]
                info_count += 1
              end
              @browser.back
              begin
                Watir::Wait.until { @browser.div(class: 'slide-row-container').visible? }
              rescue Watir::Exception::UnknownObjectException
                scrape_site(current_location)
              end
            end
          end
        end

        puts "#{info_count} products found for #{brand}".green

        puts "Grabbing product details...".yellow
        product_count = 0
        site_data = []
        product_links.each do |product_link|
          brand, link = product_link
          @browser.goto(link)
          begin
            Watir::Wait.until { @browser.h1(class: 'product-name').visible? }
          rescue Watir::Exception::UnknownObjectException
            scrape_site(current_location)
          end

          product = @browser.h1(class: 'product-name').text
          category = @browser.dl(class: 'product-categories').text
          description = @browser.div(class: 'product-description').text

          begin
            image_link = @browser.image(class: 'hidden').src
          rescue Watir::Exception::UnknownObjectException
            image_link = "NA"
          end

          site_data << {
            "brand" => brand,
            "product" => product,
            "category" => category,
            "description" => description,
            "image_link" => image_link
          }

          product_count += 1
          puts "Grabbed #{product}".green
        end
        puts "Grabbed #{product_count} products".green
        # Export to CSV
        puts "Exporting to CSV...".yellow
        column_names = site_data.first.keys
        CSV.open("site_data.csv", "a") do |csv|
          if @columns_on == true
            csv << column_names
            @columns_on = false
          end
          site_data.each do |data|
            csv << data.values
          end
        end
        puts "Exported to CSV".green
        brands_processed += 1
      end
      starting_point = nil
      @page_number += 1
    end
  rescue Watir::Exception::UnknownObjectException
    scrape_site(current_location)
  end
end

scrape_site 1
@browser.close

