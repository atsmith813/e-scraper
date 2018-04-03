# e-scraper
A friend of mine wanted to learn more about different products on a popular
e-commerce site on the West Coast. Unfortunately, the site doesn't have any solid
options to sort their products. We wanted to learn things such as most popular
product by category, most popular category, most popular brands by category, etc.
So, I wrote a script to grab all the information and export it to a CSV for further
analysis.

Full disclaimer, with this project I almost feel I learned more about what *NOT*
to do. It was very much a "learn as you go" type of experience. I discovered new
problems which I then, more or less, jammed in on top of what I already had as
opposed to more clearly re-doing some parts. But since the clock was ticking, and
I only needed to run this script once (famous last words, right?) I just got it
to work. If I were to go back, I would break out many sections of the loop into
their own methods so that it's easier to read.

## How it works
The script navigates to the all brands page of the e-commerce site. It then builds
an array of links by looping through each brand on the page and grabbing the links
to their pages.

Next, the script navigates to each brand's page. Because of the way brand pages
are set up, each category on the brand's page has a carousel of products. So
depending how many products are in that category, not all products are shown unless
you (or the script) clicks over on the carousel. However, all the product links
are still in the source code. So the script takes a similar approach, and builds
an array of all product links for that brand.

Then, it navigates to each product's page to grab the information (i.e. brand,
product, category, description, etc.) and exports it to CSV.

Finally, it goes to the next brand page found on the initial loop and repeats the
entire process again.

Once it does this for all the brands found on the first page, it then goes to the next page.

Rinse and repeat.

## Dependencies/gems
* [dotenv](https://github.com/bkeepers/dotenv "dotenv") - to manage hidden variables (i.e. URL, proxy, etc.)
* [watir](https://github.com/watir/watir "watir") - to navigate the web page of the e-commerce site programmatically
* [colorize](https://github.com/fazibear/colorize/ "colorize") - I just really like printing out pretty colors to the console to view the status of the script
* [pry](https://github.com/pry/pry "pry") - just easier to debug with

## Additional notes
I had some trouble with the script timing out randomly in different places, so
that's why you'll notice several rescue blocks. That was part me figuring out
where it was timing out and part me just trying to put a band-aid on it. In the
end I just started the scrape over from the point that it timed out. So if it was
on the 17th brand on the page, the scraper started over from the 17th brand
instead of the first.

I'm also embarrassed by some of my variable names and I learned more about how to
be better about that.

