#createCountrySynonymsFile.r

#23/5/2012 andy south
#to deal with alternative country names
#allowing a user to join dodgy names

#PERL has what I want
#http://search.cpan.org/~sbeck/Locale-Codes-3.21/lib/Locale/Codes/API.pod
#to update just copy the file Country_Codes.pm and put it in this folder

#i created a pl file to red in the pm file and output a csv I can read into R

setwd("C:\\rWorldMapData\\countryNames\\")

# to run my perl script from R
#it reads in data from pm file & outputs it to a txt file
shell("perl - w rwmCountrySynonyms.pl")

inFile <- "countrySynonyms.txt"

#reading in the csv files
ncol <- max(count.fields(inFile, sep = "\t"))

#natural earth uses ISO_A3 and they are upper case
countrySynonyms <- read.table(inFile,sep='\t', as.is=TRUE, fill=TRUE, header = FALSE
                          ,quote=""
                          ,col.names=c('ID','ISO3', paste("name", seq_len(ncol-2), sep = "")) )

#now save this into the data folder of rworldmap
save(countrySynonyms, file="C://rworldmapWorkingCopy//rworldmap//data//countrySynonyms.rda")

#create the documentation files - may need editing
#DONT run these after having edited the files
#prompt(countrySynonyms, file="c://rworldmapWorkingCopy//rworldmap//man//countrySynonyms.Rd")
#prompt(rwmGetISO3, file="c://rworldmapWorkingCopy//rworldmap//man//rwmGetISO3.Rd")

#5/10/12
#adding extra synonyms
#should I just add in by hand, or put in separetly so that I can add to Perl ones later if they are updated too
setwd("C:\\rworldmapWorkingCopy\\rworldmapSetup\\")
write.csv(countrySynonyms,file="countrySynonyms.csv",row.names=FALSE)
countrySynonyms <- read.csv("countrySynonyms.csv",as.is=TRUE)

#for now I'll edit by hand
#later I could write something to check whether there are any new additions from the Perl code & add these on
#i'm also going to add in some iso3s that are missing
str(countrySynonyms)

#name1:Gaza Strip ISO3:gaza names:Gaza
#name1:Taiwan ISO3:twn
#name1:Clipperton Island ISO3:clp
#name1:United States Minor Outlying Islands ISO3:umi
#name1:French Southern and Antarctic Lands ISO3:atf
#name1:British Indian Ocean Territory ISO3:iot
#name1:Antarctica ISO3:ata
#name1:United States names:U.S.;U.S.A.
#name1:Bosnia and Herzegovina names:Bosnia-Herzegovina
#name1:Central African Republic names:Central African Rep.
#name1:'Congo, The Democratic Republic of the' names:Congo, Dem. Rep.
#name1:Congo names:Congo, Rep.    
#name1:Cote d'Ivoire names:Ivory Coast
#name1:'Taiwan, Province of China' names:'Chinese Taipei';'Republic of China';'ROC'
#name1:China names:PRC
#iso3:prk names:Korea, Dem. Rep.
#iso3:kor names:Korea
#added : ID:282  ISO3:kos	name1:Kosovo
#iso3:mkd names:'Macedonia, FYR'
#iso3:fsm names:'Micronesia, Fed. States'
#name1:Sao Tome and Principe names:Sao Tome & Principe
#name1:Saint Helena names:St. Helena
#name1:Saint Kitts and Nevis names:St. Kitts-Nevis  St. Kitts and Nevis	St. Kitts & Nevis	Saint Kitts & Nevis
#name1:Saint Lucia names:St. Lucia
#name1:Saint Vincent and the Grenadines names:St.Vincent & Grenadines
#name1:West Bank iso3:pse names:Palestine



