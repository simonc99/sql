     select round((sum(decode(name, 'sorts (memory)', value, 0))
     / (sum(decode(name, 'sorts (memory)', value, 0))
     + sum(decode(name, 'sorts (disk)', value, 0))))
     * 100,2) as pctge_sorts_in_mem
     from v$sysstat;
