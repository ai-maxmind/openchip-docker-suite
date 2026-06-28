# Layout steps

1. Open Magic or KLayout.
2. Draw matched differential pair symmetrically.
3. Use common-centroid layout for critical pairs.
4. Add guard ring if PDK/process supports it.
5. Route power with enough width.
6. Run DRC.
7. Extract netlist.
8. Run Netgen LVS against schematic netlist.
