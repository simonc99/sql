alter index retailj.CMACTIONS_BQ_IDX_001 monitoring usage;
alter index retailj.CMACTIONS_BQ_IDX_002 monitoring usage;
alter index retailj.CMACTIONS_BQ_IDX_003 monitoring usage;
alter index retailj.CMACTIONS_BQ_IDX004 monitoring usage;

alter index retailj.CMACTIONS_BQ_IDX_001 nomonitoring usage;
alter index retailj.CMACTIONS_BQ_IDX_002 nomonitoring usage;
alter index retailj.CMACTIONS_BQ_IDX_003 nomonitoring usage;
alter index retailj.CMACTIONS_BQ_IDX004 nomonitoring usage;

# look at v$object_usage
