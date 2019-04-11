setwd("C:/Users/Kristen.Sauby/Documents/Projects/Data_Management_Workflows/R_SQL_Workflows")

library(chron)

# create fake data about the Eastern Jackalope

# JackalopeInfo
JackalopeInfo <- as.data.frame(cbind(
	IDNumber = 1:6,
	sex = rep(c("M","F"),3),
	Site = c(
		rep("Paynes Prairie", 2),
		rep("San Felasco", 2),
		rep("Ocala National Forest", 2)
	)
))

# JackalopeSurveys
JackalopeSurveys <- expand.grid(
	IDNumber = 1:6,
	SurveyDate = format(
		seq.Date(
			as.Date("2000/1/1"), by = "month", length.out = 6
		),
		"%Y-%m-%d %H:%M:%S"
	)
) %>%
	arrange(IDNumber) %>%
	as.data.frame

JackalopeSurveys$Weight <- c(
	runif(6,min=8100,max=8200),
	runif(6,min=8400,max=8500),
	runif(6,min=8900,max=9000),
	runif(6,min=9400,max=9500),
	runif(6,min=5000,max=5100),
	runif(6,min=6600,max=6700)
)

write.csv(JackalopeInfo, "./data/JackalopeInfo.csv")
write.csv(JackalopeSurveys, "./data/JackalopeSurveys.csv")






ggplot(
	JackalopeSurveys, 
	aes(
		Survey_Date, Weight, shape = factor(ID_number))) + 
	geom_point(aes(colour = factor(ID_number)), size = 4) +
	geom_point(colour = "grey90", size = 1.5)



ExporttoACCDB <- function (
	database.name = "C:/Users/Kristen.Sauby/Documents/Projects/Data_Management_Workflows/EasternJackalope.accdb", 
	x, 
	tablename = as.character(1:length(x)),
	...
){
	mycon <- dbConnect(
		drv = odbc::odbc(), 
		.connection_string = paste(
			"Driver={Microsoft Access Driver (*.mdb, *.accdb)}; Dbq=",
			database.name,
			sep=""
		)
	)
	dbWriteTable(conn=mycon, value=JackalopeInfo, name = "JackalopeInfo", overwrite=T)
	
	
	if (class(x) == "data.frame") 
		dbWriteTable(mycon, x, tablename = tablename[1])
	else for (i in 1:length(x)){
		dbWriteTable(mycon, x, tablename = tablename[1])
	} 
	close(mycon)
}



#install.packages("ImportExport")

library(ImportExport)
ExporttoACCDB(
	database.name = "C:/Users/Kristen.Sauby/Documents/Projects/Misc/DatabaseTemplate.accdb", 
	x=list(JackalopeInfo)
)





ImportExport::access_export("C:/Users/Kristen.Sauby/Documents/Projects/Misc/DatabaseTemplate.accdb",as.data.frame(JackalopeInfo),
					   tablename="JackalopeInfo")