INSTALL tpcds;
LOAD tpcds;
CALL dsdgen(sf=0.1);
COPY date_dim TO 'data/date_dim.csv';
COPY store_sales TO 'data/store_sales.csv';
COPY item TO 'data/item.csv';
