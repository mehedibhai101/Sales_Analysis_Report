let
    // 1. Access the source folder and target the specific Sales CSV file
    Source_Folder = Folder.Files("your_folder_path"),
    File_Content = Source_Folder{[Name="sales_data.csv"]}[Content],

    // 2. Import the CSV with standard encoding and promote headers
    Imported_CSV = Csv.Document(File_Content,[Delimiter=",", Columns=19, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    Promote_Headers = Table.PromoteHeaders(Imported_CSV, [PromoteAllScalars=true]),

    // 3. Remove unnecessary columns: 
    // 'Index #' is redundant in Power BI, and 'Country' is removed as it only contains "Bangladesh".
    Remove_Columns = Table.RemoveColumns(Promote_Headers,{"P_ID", "Country"}),

    // 4. Assign standardized data types
    // Using "en-US" culture for Order Date to ensure consistent parsing of M/D/YYYY formats.
    Set_Data_Types = Table.TransformColumnTypes(Remove_Columns,{
        {"Index #", Int64.Type}, {"Order ID", type text}, {"Year", Int64.Type}, {"Order Date", type date}, 
        {"Ship Mode", type text}, {"Customer ID", type text}, {"Customer Name", type text}, 
        {"Segment", type text}, {"State", type text}, {"Category", type text}, 
        {"Sub-Category", type text}, {"Sales", type number}, {"Quantity", Int64.Type}, 
        {"Discount", type number}, {"Profit", type number},
        {"Product_Name", type text}, {"Region", type text}
    }, "en-US"),

    // 5. Clean text fields to remove leading/trailing spaces for better grouping
    Trim_Text = Table.TransformColumns(Set_Data_Types, {
        {"Customer Name", Text.Trim, type text}, {"State", Text.Trim, type text}, 
        {"Category", Text.Trim, type text}, {"Sub-Category", Text.Trim, type text}, 
        {"Product_Name", Text.Trim, type text}
    }),

    // 6. Professionalize headers for clean dashboard visuals
    Renamed_Columns = Table.RenameColumns(Trim_Text,{
        {"State", "District/City"}, 
        {"Product_Name", "Product"},
        {"Sales", "Revenue"}
    }),

    // 7. Reorder columns for logical flow: Order Identity -> Timing -> Customer -> Geography -> Product -> Metrics
    Reorder_Cols = Table.ReorderColumns(Renamed_Columns, {
        "Order ID", "Order Date", "Year", "Ship Mode", "Customer ID", "Customer Name", 
        "Segment", "Region", "District/City", "Category", "Sub-Category", "Product ID", 
        "Product", "Revenue", "Quantity", "Discount", "Profit"
    })
in
    Reorder_Cols
