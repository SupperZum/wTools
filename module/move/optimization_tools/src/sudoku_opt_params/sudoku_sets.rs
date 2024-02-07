//! Sudoku sets for finding optimal parameters for solving sudoku with SA algorithm.
//! Grouped by difficulty level.

pub const TRAINING : [ &[ &str ]; 4 ] = 
// easy
[
  &[
  r#"
  080924060
  920060105
  360080029
  408209600
  106003802
  002806390
  840690070
  009705208
  075040036
  "#,
  r#"
  000079200
  000000467
  700162090
  060910720
  340087509
  090000300
  006040170
  801720040
  473000052
  "#,
  r#"
  801920000
  040850726
  056073090
  598004100
  700000530
  002600400
  900300680
  683190050
  000000013
  "#,
  r#"
  000310509
  649000801
  531080670
  210040306
  096208000
  700601080
  105900700
  900003000
  300160008
  "#,
  r#"
  000008050
  410000209
  052040000
  100020000
  003004508
  000093027
  027430896
  831560042
  900780000
  "#,
  r#"
  004020000
  030009071
  096000405
  501060000
  708912304
  309405618
  010000700
  003704000
  000230046
  "#,
  r#"
  209060038
  004508100
  605000409
  050340020
  000001000
  470006891
  000420913
  042910600
  097000204
  "#,
  r#"
  680007100
  020915807
  900603520
  056002000
  300000000
  092060058
  700056081
  008349006
  000801430
  "#,
  r#"
  000027089
  004013002
  072590300
  900401803
  047900000
  108006000
  009175200
  001060507
  005048091
  "#,
  r#"
  004100000
  000290301
  090070860
  130907582
  948506107
  002803000
  610700000
  407000210
  000080006
  "#,
  ],
  // medium
  &[
    r#"
    000042730
    308000024
    400360000
    006050840
    900403501
    500000070
    095006000
    000284956
    000005000
    "#,
    r#"
    000010032
    080900005
    000024196
    010700004
    004000050
    002050000
    920005370
    008003000
    340208001
    "#,
    r#"
    090060001
    000380040
    000400000
    100290000
    900000005
    037100960
    074030200
    203510006
    610004050
    "#,
    r#"
    260104000
    000000500
    080007029
    600500032
    000963040
    307842100
    008090600
    035000000
    000000207
    "#,
    r#"
    105000000
    670029801
    000001740
    060000300
    381050006
    059010070
    007032000
    900000100
    004000507
    "#,
    r#"  
    000800690
    026309085
    001000007
    070002560
    000098000
    038060920
    000027050
    600000030
    004600700
    "#,
    r#"
    000005071
    000001000
    751482000
    190203700
    802010005
    006000100
    603024000
    000350200
    024000308
    "#,
    r#"
    006300000
    740801056
    000026040
    060000000
    300100500
    100008700
    608000420
    402087010
    010050003
    "#,
    r#"
    080070030
    260050018
    000000400
    000602000
    390010086
    000709000
    004000800
    810040052
    050090070
    "#,
  ],
  // hard
  &[
    r#"
    000700208
    000800090
    284160050
    410080060
    008516000
    000090000
    002000500
    801070040
    000030000
    "#,
    r#"
    007000302
    200005010
    000801400
    010096008
    760000049
    000000000
    000103000
    801060000
    000700063
    "#,
    r#"
    080000090
    070060210
    006048700
    800000530
    020000000
    163000000
    000401900
    000000070
    209700005
    "#,
    r#"
    020060000
    905040000
    000007452
    801020043
    009800600
    006400008
    500000000
    030005970
    700000805
    "#,
    r#"
    000500084
    038000200
    005000000
    514060070
    007080009
    820070561
    051006000
    000000005
    402053100
    "#,
    r#"
    016400000
    200009000
    400000062
    070230100
    100000003
    003087040
    960000005
    000800007
    000006820 
    "#,
    r#"
    049008605
    003007000
    000000030
    000400800
    060815020
    001009000
    010000000
    000600400
    804500390 
    "#,
    r#"
    000605000
    003020800
    045090270
    500000001
    062000540
    400000007
    098060450
    006040700
    000203000 
    "#,
    r#"
    409000705
    000010000
    006207800
    200000009
    003704200
    800000004
    002801500
    000060000
    905000406 
    "#,
    r#"
    000010030
    040070501
    002008006
    680000003
    000302000
    300000045
    200500800
    801040020
    090020000
    "#,
  ],
  // expert
  &[
    r#"
    000000690
    028100000
    000000005
    600400301
    030050000
    009000080
    100030040
    396507000
    080000000
    "#,
    r#"
    008906005
    043000020
    000000000
    004000900
    500040680
    000100000
    200080070
    000034100
    060009000
    "#,
    r#"
    000000000
    590034600
    060000080
    400008009
    010000076
    000000500
    070900003
    300800260
    050070000
    "#,
    r#"
    050900000
    200000400
    001608020
    000030000
    070000005
    006201040
    000090080
    003040000
    060803700
    "#,
    r#"
    200000008
    700090000
    605030000
    300000600
    008407900
    100680000
    003200001
    050000006
    000800040
    "#,
    r#"
    760500000
    000060008
    000000403
    200400800
    080000030
    005001007
    809000000
    600010000
    000003041 
    "#,
    r#"
    090050800
    803060002
    040300000
    000005004
    608700500
    900000000
    030000000
    507600400
    000020010
    "#,
    r#"
    000670050
    087004003
    100000000
    400000001
    900002000
    021050030
    000040800
    032008007
    090000000
    "#,
    r#"
    083090750
    500000002
    000700006
    300100870
    000000600
    001020000
    000000005
    800200130
    090004000
    "#,
    r#"
    100500600
    020700000
    008026003
    900000008
    000600000
    050041300
    005000040
    040032100
    000070000
    "#,
    r#"
    160000700
    094070020
    000001000
    000005002
    009806400
    400100000
    000500000
    040080390
    003000046
    "#,
  ],
];

pub const CONTROL : [ &[ &str ]; 4 ] = 
[
  // easy
  &[
    r#"
    068027901
    000910008
    107003040
    470206000
    051349700
    020870350
    019060000
    030500006
    605000407
    "#,
    r#"
    984007100
    010590008
    257803000
    802005090
    045009802
    000248307
    400030000
    008401200
    060902400
    "#,
    r#"
    630000050
    205340000
    000006900
    070690500
    000013740
    002000030
    310984075
    729035086
    004000091
    "#,
    r#"
    080072001
    050031649
    000040807
    008050400
    040000208
    601200050
    920763080
    070010062
    165900300
    "#,
    r#"
    001070009
    609831750
    807009006
    004900100
    080063000
    000410073
    000107230
    210390500
    053204600
    "#,
  ],
  // medium
  &[
    r#"
    096751000
    000603040
    003400006
    500206084
    000130200
    807005000
    005007020
    062000000
    000809001
    "#,
    r#"
    000001506
    005600000
    800040009
    008100740
    002000000
    004580001
    500809030
    700300060
    409062015
    "#,
    r#"
    004000000
    087010304
    900000500
    009002650
    100008000
    508004201
    020049010
    300800000
    890056007
    "#,
    r#"
    600500208
    908072305
    200030490
    087005000
    000000851
    000020000
    803100000
    000000002
    069004530
    "#,
    r#"
    000009000
    000854793
    079003000
    700042901
    003900840
    900000060
    208000054
    400320000
    000405620
    "#,
  ],
  // hard
  &[
    r#"
    600500080
    040006090
    010000700
    000008300
    920050017
    003100000
    005000070
    090800020
    060004001 
    "#,
    r#"
    900703004
    600090200
    007060000
    080000500
    006040700
    009000080
    000050800
    001020003
    200901005 
    "#,
    r#"
    005000080
    700405000
    090600705
    200000006
    001204800
    300000004
    903002010
    000506009
    070000200 
    "#,
    r#"
    480000019
    000000000
    007010300
    001604900
    004000800
    060070020
    009701500
    028050730
    000030000
    "#,
    r#"
    400000380
    060580490
    000000506
    000012000
    000000800
    284007169
    600100900
    001940275
    000000030
    "#,
  ],
  // expert
  &[
    r#"
    035000006
    000070800
    001009000
    920000078
    050000020
    300000500
    000500010
    094000200
    000607004
    "#,
    r#"
    300400090
    000000064
    800090100
    000000000
    030002900
    500010700
    070050300
    020100607
    060040000
    "#,
    r#"
    090050800
    803060002
    040300000
    000005004
    608700500
    900000000
    030000000
    507600400
    000020010
    "#,
    r#"
    000670050
    087004003
    100000000
    400000001
    900002000
    021050030
    000040800
    032008007
    090000000
    "#,
    r#"
    083090750
    500000002
    000700006
    300100870
    000000600
    001020000
    000000005
    800200130
    090004000
    "#,
  ]
];