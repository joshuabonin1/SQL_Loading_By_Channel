This project was to create a dashbord with visuals to show loading percentage, by both channel (Type of Inventory) and user type, also as a function of total loading percentage.
I created each of the three types of modules shown for 6 dispatches. Dashboard contains a total of 18 modules.
Loading By Channel Module:
  This is a bar chart visual displaying loading percentage for each Channel, filtered by percentage loaded by RF devices and percentage loaded by "Tasker", meaning computer loaded. A third bar shows total loading percentage, regardless of how it was loaded.
Loading By Channel Detail Module:
  This is a traditional table visual displaying the same information in the Loading By Channel module, just less visual and more number focused. This was created to be emailed to site leadership every morning for the loading done the day prior.
Loading By Carton Type Module:
  This is a traditional table visual displaying the detail of the previous two modules. Each channel represents a type of product, and has several carton types within it. The JPG for this is the detail module shown from cliking on the "Wholesale" bar, or the "Wholesale" row from the previously mentioned modules.
These modules were created utilizing several Common Table Expressions (CTEs) to organize the data based on how it was loaded.
The commented out section was removed, resulting in cutting run time down by 50% and improving accuracy.
