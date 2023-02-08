-- Allen Kong Graphics

function define_allen_big()
	local palette = {}
	palette["X"] = 0xff000000
	palette["!"] = 0xff644828
	palette["#"] = 0xff3a240c
	palette["^"] = 0xff886d4d
	palette["%"] = 0xff6f240c
	palette["="] = 0xffc09167
	palette["'"] = 0xfff9b68d
	palette["("] = 0xffffdaa8
	palette[")"] = 0xffb66d4d
	palette["*"] = 0xffd2b6b6
	palette["+"] = 0xffdadac2
	palette[","] = 0xff919175
	palette["-"] = 0xffffffec
	palette["."] = 0xff91b691
	palette["/"] = 0xffff917f
	palette["0"] = 0xffb691b6
	
	local data = {
		"             ! #######!               ",
		"      !   #!X^!!###X##XX#             ",
		"    # ! #####!%%!!X^^!XX#             ",
		"    #^#^^!######XX^==''==#            ",
		"   !^!!^#X!#!#XX#='''''''('           ",
		"  !!#X#XX!!^^X#)=''''''''((*          ",
		"  ##XXX####X!)=''''''''''''(+         ",
		"#XXXXXX!#X^))'''''''''''''''(#        ",
		"XXXXX#XX!=))''''''''''''''''((^       ",
		"##XX##X!=='''''''''''''=)%=''(X       ",
		"####X#X#)'='''''''''=)!!''''''=       ",
		"##X!X###)')^'''''==% ^'''''=!=(       ",
		"#####X##)')#('''''''''=''=)=''(!      ",
		"###X##X!)')#('''''')!#!=''''''(+      ",
		"!#!####^='=!!(''''==''''''''''=#      ",
		"!!^^!##=)''=X('''=!'''''''''''X^!     ",
		"!!#!!! #=''=#'('''''''''''''(^#X      ",
		"!##X!!!#)'''^!(''''''==!)''''!,!#     ",
		"!#!X##!!)'''==('''')XXXX#=''=XX+,X!   ",
		"##^!#!#X)'''^*(''''!^,,#XX#!XX*#XX!   ",
		" ######X)='''''''''!XX#,^,==*=X#==    ",
		" ####X!#X=''''''''(X#^##X^)%''X!!#=   ",
		" X#XXX#XX=='''''''#^!X,=-#!%='^XX=(#  ",
		" X#XX*X!*X=)===^!###XXX^*^!'''((X^(   ",
		" #X#X*,!X=^=''''''==^=''##''''(('#'   ",
		"  X#X()##=%='''''''!''(X!''''''('^'   ",
		"  #XX')#^!!=''''''''=='''''X!'''''^(  ",
		"    X'==!^!'='''''''''('''' ,^))='!(# ",
		"   !X'=')!=''''''''((((('''XXXX#!X''# ",
		"      '''^)='''''''((((('''=)===^=!=^ ",
		"       ^=%%%)''''''((((('''))=)!#X!'^ ",
		"        !'('#='''''''((''''==)X#.!%=! ",
		"         '==()'''''''''''''''X-(XX)=# ",
		"             X=('''''''''''' !!%%#='# ",
		"             ^ =('''''''''^#XXXXX#)'  ",
		"             !!!'(''''''''!^X=%/!=!^  ",
		"              ^^^((''''''''='#))X0!=  ",
		"              !=)=('('=''''''' ^^#='  ",
		"               #)==''''''''''''#!'*X  ",
		"                ^=)('''='''''''''(X!! ",
		"                  #=(('===)''''=! ='^ ",
		"                   #=''/))!)='''''''^ ",
		"                     ^='=^^)=='('''   ",
		"                       ^===!#^=))!    ",
		"                        !^==^XXX      ",
		"                           !)^^       ",
		"                                      "}
	return {data, palette}
end

function define_allen_small()
	palette = {}
	palette["!"] = 0xff20130d
	palette["#"] = 0xff4f2412
	palette["+"] = 0xff6a3e29
	palette["*"] = 0xff8e5a41
	palette["&"] = 0xffad7e67
	palette["'"] = 0xffc59f8b
	palette["("] = 0xffddc2b4

	data = {
		"   !!#+#+#!     ",
		"  !******++#    ",
		" !++*&'''''&#!  ",
		" #++'(((((((&#  ",
		"!*#*(((((((((*! ",
		"###&((((((((('+ ",
		"*##&((((((((((+ ",
		"*##&''''&#+*'*# ",
		"*##+#######**+**",
		"+*++'''*&'&&''''",
		"+*&+&((((''''(&!",
		"!&&*'(((('(&'(* ",
		"!*'''(((('&***! ",
		" #*''((((''&**! ",
		"  #*''((('&+*+! ",
		"    &'((('''''# ",
		"    !''(('''''+ ",
		"     #+'(''((&! ",
		"       !+&&&*!  "}
	return {data, palette}
end

function define_fack_left()
	palette = {}
	palette["!"] = 0xffffffff
	
	local data = {
		"                                     !!!!!!!!!!!!!!!!!",
		"                                  !!!!!!!!!!!!!!!!!!!!!!!",
		"                                !!!!                   !!!!!",
		"                              !!!                         !!!!",
		"                            !!!                             !!!!",
		"                          !!!                                 !!!!",
		"                        !!!                                     !!!!",
		"                       !!!                                        !!!",
		"                     !!!                          !!                !!!",
		"                    !!!                         !!!!!                !!!",
		"                  !!!                           !!!!!                 !!",
		"                !!!!                            !!!!!                  !!",
		"              !!!                               !!!!!                   !!",
		"            !!!                                  !!!!!                  !!",
		"          !!!                                    !!!!!                   !!",
		"         !!!                                      !!!!    !!             !!",
		"        !!!                                       !!!!   !!!!            !!",
		"       !!!                                         !!!  !!!!             !!",
		"       !!                                          !!!! !!!              !!",
		"      !!                                           !!!!!!!!              !!",
		"     !!                                             !!!!!!               !!",
		"     !!                                             !!!!!!               !!",
		"    !!                                              !!!!!!               !!",
		"   !!              !!!!!!                            !!!!!!!!!!          !!",
		"   !!            !!!!!!!!!                   !!      !!!!!!!!!!!         !!",
		"  !!           !!!!!!!!!!!                  !!!!!    !!!!!!!!!!!!        !!",
		"  !!         !!!!!!!!!!!!!!                !!!!!!!   !!!!!!!!!!!!!       !!",
		" !!         !!!!!!!!!!!!!!!               !!!!!!!!    !!!!   !!!!!       !!",
		"!!          !!!!!!!!!!!!!!!              !!!!!!!!!    !!!!   !!!!!!      !!",
		"!!          !!!!!!!!!   !!!              !!!! !!!     !!!!    !!!!!      !!",
		"!!          !!!!!!!!                    !!!!          !!!!!   !!!!!      !!",
		"!!          !!!!!!              ! !     !!!!           !!!!    !!!!!    !!",
		"!!          !!!!!!           !  ! !  !  !!!!       !   !!!!!   !!!!     !!",
		"!!           !!!!     !!!     ! ! ! !    !!!     !!!!  !!!!!   !!!      !!",
		"!!           !!!!!  !!!!!!   ! !!!!! !   !!!!    !!!!  !!!!!            !!",
		"!!            !!!!!!!!!!!!    !!!!!!!     !!!!  !!!!!   !!!!!           !!",
		"!!            !!!!!!!!!!!!  !!!!!!!!!!!   !!!!!!!!!!!   !!!!!          !!",
		"!!            !!!!!!!! !!     !!!!!!!      !!!!!!!!!    !!!!           !!",
		"!!             !!!!!         ! !!!!! !     !!!!!!!!!                   !!",
		"!!             !!!!!          ! ! ! !       !!!!!!                    !!",
		"!!             !!!!!         !  ! !  !       !!!                      !!",
		"!!              !!!!            ! !                                  !!",
		"!!              !!!!                                                 !!",
		" !!             !!!!!                                               !!",
		" !!              !!!!                                               !!",
		"  !!             !!!!                                              !!",
		"  !!             !!!!                                             !!",
		"   !!            !!!!                                             !!",
		"    !!           !!!!                                            !!",
		"     !!          !!!!!                                          !!",
		"     !!          !!!!!                                        !!!",
		"      !!           !!                                       !!!",
		"       !!                                                 !!!",
		"        !!                                            !!!!",
		"         !!                                       !!!!",
		"          !!                                 !!!!!",
		"           !!                             !!!!",
		"            !!                       !!!!!!",
		"             !!               !!!!!!!!",
		"             !!         !!!!!!!!!",
		"              !!      !!!!!!",
		"               !!   !!!",
		"               !!   !!",
		"               !!  !!",
		"               !!  !!",
		"               !! !!",
		"               !! !!",
		"               !! !!",
		"               !! !!",
		"               !! !!",
		"                !!!",
		"                !!",
		"                !!",
		"                !"}
	return {data, palette}
end

function define_fack_right()
	palette = {}
	palette["!"] = 0xffffffff
	
	data = {
		"                                     !!!!!!!!!!!!!!!!!",
		"                                  !!!!!!!!!!!!!!!!!!!!!!!",
		"                                !!!!                   !!!!!",
		"                              !!!                         !!!!",
		"                            !!!                             !!!!",
		"                          !!!                                 !!!!",
		"                        !!!                                     !!!!",
		"                       !!!                                        !!!",
		"                     !!!                          !!                !!!",
		"                    !!!                         !!!!!                !!!",
		"                  !!!                           !!!!!                 !!",
		"                !!!!                            !!!!!                  !!",
		"              !!!                               !!!!!                   !!",
		"            !!!                                  !!!!!                  !!",
		"          !!!                                    !!!!!                   !!",
		"         !!!                                      !!!!    !!             !!",
		"        !!!                                       !!!!   !!!!            !!",
		"       !!!                                         !!!  !!!!             !!",
		"       !!                                          !!!! !!!              !!",
		"      !!                                           !!!!!!!!              !!",
		"     !!                                             !!!!!!               !!",
		"     !!                                             !!!!!!               !!",
		"    !!                                              !!!!!!               !!",
		"   !!              !!!!!!                            !!!!!!!!!!          !!",
		"   !!            !!!!!!!!!                   !!      !!!!!!!!!!!         !!",
		"  !!           !!!!!!!!!!!                  !!!!!    !!!!!!!!!!!!        !!",
		"  !!         !!!!!!!!!!!!!!                !!!!!!!   !!!!!!!!!!!!!       !!",
		" !!         !!!!!!!!!!!!!!!               !!!!!!!!    !!!!   !!!!!       !!",
		"!!          !!!!!!!!!!!!!!!              !!!!!!!!!    !!!!   !!!!!!      !!",
		"!!          !!!!!!!!!   !!!              !!!! !!!     !!!!    !!!!!      !!",
		"!!          !!!!!!!!                    !!!!          !!!!!   !!!!!      !!",
		"!!          !!!!!!              ! !     !!!!           !!!!    !!!!!    !!",
		"!!          !!!!!!           !  ! !  !  !!!!       !   !!!!!   !!!!     !!",
		"!!           !!!!     !!!     ! ! ! !    !!!     !!!!  !!!!!   !!!      !!",
		"!!           !!!!!  !!!!!!   ! !!!!! !   !!!!    !!!!  !!!!!            !!",
		"!!            !!!!!!!!!!!!    !!!!!!!     !!!!  !!!!!   !!!!!           !!",
		"!!            !!!!!!!!!!!!  !!!!!!!!!!!   !!!!!!!!!!!   !!!!!          !!",
		"!!            !!!!!!!! !!     !!!!!!!      !!!!!!!!!    !!!!           !!",
		"!!             !!!!!         ! !!!!! !     !!!!!!!!!                   !!",
		"!!             !!!!!          ! ! ! !       !!!!!!                    !!",
		"!!             !!!!!         !  ! !  !       !!!                      !!",
		"!!              !!!!            ! !                                  !!",
		"!!              !!!!                                                 !!",
		" !!             !!!!!                                               !!",
		" !!              !!!!                                               !!",
		"  !!             !!!!                                              !!",
		"  !!             !!!!                                              !!",
		"   !!            !!!!                                              !!",
		"    !!           !!!!                                             !!",
		"     !!          !!!!!                                            !!",
		"     !!          !!!!!                                           !!",
		"      !!           !!                                            !!",
		"       !!                                                       !!",
		"        !!                                                     !!",
		"         !!                                                   !!",
		"          !!!!                                                !!",
		"             !!!!!!!!!                                       !!",
		"                     !!!!!!!!!!!                            !!",
		"                               !!!!!!!!!!!!                 !!",
		"                                          !!!!!!!!!!!!!    !!",
		"                                                      !!   !!",
		"                                                      !!   !!",
		"                                                      !!  !!",
		"                                                       !! !!",
		"                                                       !! !!",
		"                                                       !! !!",
		"                                                       !! !!",
		"                                                        !!!!",
		"                                                         !!!",
		"                                                          !!",
		"                                                          !!",
		"                                                           !"}
	return {data, palette}
end

function define_finger()
	palette = {}
	palette["!"] = 0xffffffff	

	data = {
		"                       !!!!!!!!!                              ",
		"                    !!!!!     !!!                             ",
		"                   !!!!        !!!                            ",
		"                  !!!  !!!!!!!  !!                            ",
		"                 !!! !!!     !! !!!                           ",
		"                 !!  !        !  !!                           ",
		"                 !!  !        !  !!                           ",
		"                 !!  !        !  !!                           ",
		"                 !!  !!      !!  !!                           ",
		"                 !!  !!      !!  !!!                          ",
		"                 !!   !     !!    !!                          ",
		"                 !!!  !!!!!!!     !!                          ",
		"                  !!              !!                          ",
		"                  !!              !!                          ",
		"                  !!              !!                          ",
		"                  !!              !!!                         ",
		"                  !!               !!                         ",
		"                  !!!   !!!!!!     !!                         ",
		"                   !!              !!                         ",
		"                   !!              !!                         ",
		"                   !!    !!!!!!    !!                         ",
		"                   !!!             !!!                        ",
		"                    !!              !!                        ",
		"                    !!              !!!                       ",
		"                    !!             !!!!!                      ",
		"                    !!!     !!!!!!!!!!!!    !!!!!             ",
		"                     !!   !!    !!!!!!!!  !!!!!!!!!!          ",
		"                   !!!!!!!!     !!!!!!!!!!!!!   !!!!!         ",
		"                   !!!!!!!!     !!!!!!!!!!        !!!!        ",
		"                   !!!!!!!!     !    !!!!           !!!       ",
		"                   !!!!!!!!!   !!    !!!             !!!      ",
		"                    !!!!!  !!!!!     !!               !!!     ",
		"                      !!!                              !!!    ",
		"                       !!                              !!!    ",
		"                   !!! !!                               !!!   ",
		"               !!!!!!!!!!!                              !!!   ",
		"             !!!!!!!!!!!!!                               !!   ",
		"            !!!!        !!                    !!         !!!  ",
		"          !!!!           !!                   !!          !!  ",
		"          !!!                                  !          !!  ",
		"         !!!                                   !          !!  ",
		"         !!                                    !          !!  ",
		"       !!!!                                    !           !! ",
		"     !!!!!                                     !!          !! ",
		"    !!!!                                        !          !! ",
		"   !!!                       !                  !          !! ",
		"  !!!                        !                  !          !! ",
		"  !!!                        !!                 !!         !! ",
		" !!!                          !!                !!          !!",
		" !!                           !!                            !!",
		"!!                             !                            !!",
		"!!            !!                                            !!",
		"!!             !!                                           !!",
		"!!              !!                                          !!",
		"!!               !!                                         !!",
		"!!                !!                                        !!",
		"!!                 !!                                       !!",
		" !!                 !!                                     !! ",
		" !!!                                                       !! ",
		"  !!!                                                      !! ",
		"   !!                                                      !! ",
		"   !!!                                                    !!  ",
		"    !!!                                                   !!  ",
		"     !!!                                                 !!!  ",
		"     !!!!                                                !!   ",
		"      !!!                                               !!!   ",
		"       !!!                                             !!!    ",
		"        !!!                                            !!     ",
		"         !!!                                          !!!     ",
		"          !!!!                                      !!!!      ",
		"           !!!!                                    !!!!       ",
		"            !!!!                                 !!!!!        ",
		"              !!!!                             !!!!!          ",
		"               !!!!!                        !!!!!!            ",
		"                  !!!!                   !!!!!!!              ",
		"                   !!!!!!              !!!!!!                 ",
		"                     !!!!!!!         !!!!!                    ",
		"                        !!!!!!!!!!!!!!!!                      ",
		"                           !!!!!!!!!!!                        " }
	return {data, palette}
end

function define_restricted()
	local palette = {}
	palette["!"] = 0xffff0000
	palette["+"] = 0xffffffff
	
	local data = {
		"                       !!!                                                        ",
		"                      !!!!!                                                       ",
		"                     !!!!!!!                                                      ",
		"                    !!!! !!!!                                                     ",
		"                   !!!!   !!!!                                                    ",
		"                  !!!!     !!!!                                                   ",
		"                 !!!!       !!!!                                                  ",
		"                !!!!         !!!!                                                 ",
		"               !!!!           !!!!                                                ",
		"              !!!!             !!!!                                               ",
		"             !!!!               !!!!                                              ",
		"            !!!!                 !!!!                                             ",
		"           !!!!!!!!!!!!!!!!!      !!!!                                            ",
		"          !!!! !!!!!!!!!!!!!!!     !!!!                                           ",
		"         !!!!  !!!!!!!!!!!!!!!!     !!!!              !!!    !!!!!!!              ",
		"        !!!!   !!!!!!!!!!!!!!!!!     !!!!            !!!!   !!!!!!!!!             ",
		"       !!!!    !!!!!!!!!!!!!!!!!!     !!!!         !!!!!!  !!!!!!!!!!!            ",
		"      !!!!     !!!!!!     !!!!!!!      !!!!        !!!!!!  !!!!   !!!!            ",
		"     !!!!      !!!!!!      !!!!!!       !!!!       !!!!!!  !!!     !!!            ",
		"    !!!!       !!!!!!      !!!!!!        !!!!         !!!  !!!     !!!            ",
		"   !!!!        !!!!!!      !!!!!!         !!!!        !!!  !!!!   !!!!      !!    ",
		"  !!!!         !!!!!!     !!!!!!!          !!!!       !!!   !!!!!!!!!       !!    ",
		" !!!!          !!!!!!!!!!!!!!!!!!           !!!!      !!!    !!!!!!!        !!    ",
		"!!!!           !!!!!!!!!!!!!!!!!             !!!!     !!!   !!!!!!!!!       !!    ",
		"!!!!           !!!!!!!!!!!!!!!!              !!!!     !!!  !!!!   !!!! !!!!!!!!!!!",
		" !!!!          !!!!!!!!!!!!!!!              !!!!      !!!  !!!     !!! !!!!!!!!!!!",
		"  !!!!         !!!!!!!!!!!!!!              !!!!       !!!  !!!     !!!      !!    ",
		"   !!!!        !!!!!!   !!!!!!            !!!!        !!!  !!!     !!!      !!    ",
		"    !!!!       !!!!!!   !!!!!!           !!!!         !!!  !!!!   !!!!      !!    ",
		"     !!!!      !!!!!!   !!!!!!!         !!!!          !!!  !!!!!!!!!!!      !!    ",
		"      !!!!     !!!!!!    !!!!!!!       !!!!           !!!   !!!!!!!!!             ",
		"       !!!!    !!!!!!    !!!!!!!      !!!!            !!!    !!!!!!!              ",
		"        !!!!   !!!!!!     !!!!!!!    !!!!                                         ",
		"         !!!!  !!!!!!     !!!!!!!   !!!!                                          ",
		"          !!!! !!!!!!      !!!!!!! !!!!                                           ",
		"           !!!!!!!!!!      !!!!!!!!!!!                                            ",
		"            !!!!                 !!!!                                             ",
		"             !!!!               !!!!                                              ",
		"              !!!!             !!!!                                               ",
		"               !!!!           !!!!                                                ",
		"                !!!!         !!!!                                                 ",
		"                 !!!!       !!!!                                                  ",
		"                  !!!!     !!!!                                                   ",
		"                   !!!!   !!!!                                                    ",
		"                    !!!! !!!!                                                     ",
		"                     !!!!!!!                                                      ",
		"                      !!!!!                                                       ",
		"                       !!!                                                        ",
		"",
		"",
		"",
		"",
		"",
		"  +++++   ++++++   ++++   ++++++  +++++   ++++++   ++++   ++++++  ++++++  +++++   ",
		"  ++  ++  ++      ++        ++    ++  ++    ++    ++  ++    ++    ++      ++  ++  ",
		"  +++++   ++++     ++++     ++    +++++     ++    ++        ++    ++++    ++  ++  ",
		"  ++  ++  ++          ++    ++    ++  ++    ++    ++  ++    ++    ++      ++  ++  ",
		"  ++  ++  ++++++   ++++     ++    ++  ++  ++++++   ++++     ++    ++++++  +++++   "}
		return {data, palette}
end		

function define_balloon()
	local palette = {}
	palette["a"] = 0xff2038ec
	palette["b"] = 0xfffcd8a8

	local data = {
		"   aaaa   ",
		"  aaaaaa  ",
		" aabaaaaa ",
		" abaaaaaa ",
		"aabaaaaaaa",
		"aaaaaaaaaa",
		" aaaaaaaa ",
		" aaaaaaaa ",
		"  aaaaaa  ",
		"   aaaa   ",
		"    b     ",
		"   b      "}
	return {data, palette}
end

function define_10yard()
	local palette = {}
	palette["+"] = 0xff14f3ff

	local data = {
		"  +",
		" ++                               ++",
		"+++    ++++                         +",
		"  +   +    +                         +",
		"  +   +    +                         +",
		"  +   +    +                         +",
		"  +   +    +  +  +    +++   +++   ++++",
		"  +   +    + ++  +  ++  +  + +  ++   +",
		"  +    +  +   + ++ + +  + +  + + +  ++",
		"  +     ++    ++ ++  +++++   ++  ++++",
		"                 +",
		"                 +",
		"                 +",
		"              +  +",
		"               ++"}
	return {data, palette}
end

function define_lukey()
	local palette = {}
	palette["#"] = 0xff14f3ff

	local data = {
		"#       #     # #    # ####### #     #    ###  #####        #       #       #######  #####  ####### #     # ######      #####  #     # ######   #####  #     # #     # #######   #    #####   #####",
		"#       #     # #   #  #        #   #      #  #     #      # #      #       #       #     # #       ##    # #     #    #     # ##   ## #     # #     # ##    # #     #    #     ##   #     # #     #",
		"#       #     # #  #   #         # #       #  #           #   #     #       #       #       #       # #   # #     #    # ### # # # # # #     #       # # #   # #     #    #    # #         #       #",
		"#       #     # ###    #####      #        #   #####     #     #    #       #####   #  #### #####   #  #  # #     #    # ### # #  #  # ######   #####  #  #  # #     #    #      #    #####   #####",
		"#       #     # #  #   #          #        #        #    #######    #       #       #     # #       #   # # #     #    # ####  #     # #   #   #       #   # # #     #    #      #   #             #",
		"#       #     # #   #  #          #        #  #     #    #     #    #       #       #     # #       #    ## #     #    #       #     # #    #  #       #    ## #     #    #      #   #       #     #",
		"#######  #####  #    # #######    #       ###  #####     #     #    ####### #######  #####  ####### #     # ######      #####  #     # #     # ####### #     #  #####     #    ##### #######  #####"
	}
	return {data, palette}
end

function define_chars()
	local data = {}
	data["0"] = 0x0
	data["1"] = 0x1
	data["2"] = 0x2
	data["3"] = 0x3
	data["4"] = 0x4
	data["5"] = 0x5
	data["6"] = 0x6
	data["7"] = 0x7
	data["8"] = 0x8
	data["9"] = 0x9
	data[" "] = 0x10
	data["A"] = 0x11
	data["B"] = 0x12
	data["C"] = 0x13
	data["D"] = 0x14
	data["E"] = 0x15
	data["F"] = 0x16
	data["G"] = 0x17
	data["H"] = 0x18
	data["I"] = 0x19
	data["J"] = 0x1a
	data["K"] = 0x1b
	data["L"] = 0x1c
	data["M"] = 0x1d
	data["N"] = 0x1e
	data["O"] = 0x1f
	data["P"] = 0x20
	data["Q"] = 0x21
	data["R"] = 0x22
	data["S"] = 0x23
	data["T"] = 0x24
	data["U"] = 0x25
	data["V"] = 0x26
	data["W"] = 0x27
	data["X"] = 0x28
	data["Y"] = 0x29
	data["Z"] = 0x2a
	data["-"] = 0x2c
	data["."] = 0x2b
	data[":"] = 0x2e
	data["("] = 0x30
	data[")"] = 0x31
	data["!"] = 0x38
	data["'"] = 0x3a
	data["["] = 0x49  -- copyright 1
	data["]"] = 0x4a  -- copyright 2
	data["*"] = 0xc0  -- ladder
	data["?"] = 0xfb
	return data
end

function define_level_lookup()
	local data = {}
	data[1] = 12
	data[2] = 05
	data[4] = 01
	data[8] = 17
	return data
end

function define_level_data()
	-- start_score, select y pos, select x pos
	local data = {}
	data[1]  = {"000000",176,073}
	data[5]  = {"100000",136,001}
	data[12] = {"471000",136,145}
	data[17] = {"736000",096,073}
	return data
end

-- Allen Kong Sounds

function define_sounds()
	data = {}

	data["startup"] = {
		"got_swearing", "adults_only"
	}

	data["logo"] = {
		"bullshitgame", "best_romhack", "inthegame", "called_allenkong", "exciting_game", "easports", "playthegame",
		"gallopingghosts", "welcome_musclefitness", "get_the_wr", "fullgrownman", "changes_color", "renstimpy",
		"boomerang", "mammamia", "im_allen", "true_champ", "goodhighscore", "thisisdonkeykong"
	}

	data["ambient"] = {
		"hello_anyone_there", "hottubclassic", "classic", "ownvideogame", "thefans", "bigfartbrian",
		"hahahaha",	"hehehehe",	"errr",	"cat", "cough",	"blub",	"gotten_better", "cough2", "gunfight",
		"its_me_mario", "finkel", "2viewers", "bigmac", "smile", "hey_olives", "help_popeye", "hills",
		"pogo_stick", "something", "alltheway", "zookeeper", "raidsomebody", "taxi", "dandruff", "everywhere",
		"brianfart", "brianfart2", "brianfart3", "brianfart4", "brianfart5", "jcb_fart", "yeahfart",
		"fart1", "fart2", "fart3", "fart4", "fart5","fart6", "fart7", "fart8",
		"burp1", "burp2", "burp3", "burp4", "burp5", "burp6",
		"continue", "positive", "gimmethatknife", "manamana", "major_tom", "major_tom_2",
		"letsgo", "btch_tit", "wakeup_brian", "machine_on_fire", "brian_looking", "thistime",
		"bumpbadump", "dodododo", "good_ong", "hey_buddy", "polish_knob", "crocodile_dundee",
		"that_aint_a_knife", "yes_i_love", "own_kongoff", "sometune", "lukey_legend",
		"dkmorningnight", "play_dk_song", "royschultz", "itssteve", "wes_believe", "row_jcb", "looneytunes",
		"blueberryhill", "c_hair_song", "lalalala", "play_properly", "yogi", "koalabear", "bangor", "yellowriver",
		"jcb", "shananana", "drop_doritos", "come_see_me_play", "phil_pretender", "jcb_shake", "missile_command",
		"what_can_i_do", "canwegetamillion", "inthebeginning", "getoutofhere", "mario_doreme", "pissing",
		"ijustwannahavefun", "getoutofhere", "mrmayagi", "want1m", "igotmuscleandfitness", "skypein", "aliendust",
		"restaurant", "girlfriend", "watchthegame"
	}

	data["complete"] = {
		"lickballsack",	"lickballsack",	"fackyoubitch",	"gofackyourself", "idiotonchannel",	"brianallennerd", "ggf",
		"catch_brian", "popeye", "mo", "pauline", "easports", "whore", "allensayseasports", "c_hair", "c_hair2",
		"lookatthepace", "lick_it_allen", "pauline_inthegame", "save_pauline", "george", "arrr_whoo", "dirty",
		"conqueror", "goodscore_noworries", "roadhog", "i_can_get_more", "porkypig", "facking_whr", "rowrowkong",
		"my_and_wes_way", "itsmagic2", "omg_balls", "head", "trying_highscore", "ks_everygame", "something_right",
		"haaarhah", "lickmy", "recordbook", "pro"
	}

	data["grab"] = {
		"dush_dush", "here_chick_chick", "yeheee", "love_it", "something2", "hey", "suckemin",
		"cometopapa", "cometopapa2", "dush_dush2", "yepyep", "allenkongbaby", "yehbuddy", "lookathat", "whoo_cmon",
		"come_on_baby_1m", "lookatemall", "come_lovelies", "duke_suckemin", "the_duke", "come_on_fs",
		"fernando", "suck", "yeppew", "horse", "hunting_fireballs", "hammer_me", "cmon_fireballs", "yipyipyipyipyip"
	}

	data["highscore"] = {
		"nohighscore", "notgoodenough", "new_wr", "nevergetit", "999999", "neverwill", "spreading_news",
		"highscore_singit", "itsmagic", "today_score", "lookma", "notplayanymore"
	}

	data["bonus800"]= {
		"unbelieveable", "omg_loveit", "bigbigbig", "nice", "yes", "lick_on_that", "lick_it", "ohyeah_ohyeah", "wow800",
		"whoopiedo", "take_that", "lick_that", "woohoo", "800baby"
	}

	data["jump800"] = {
		"lakeman", "lukey", "likeserph", "practising", "deserves_million", "phil_loves_it", "lukey_loves", "oyoyoy",
		"serphy_brother", "like_it_matt", "like_a_glove", "readwellphil", "serphy", "lakeman_luck", "oh800", "wow800",
		"lickthatlakeman", "ohrobby", "spaceylovesit", "onpaper", "dukey_loves_it", "hehe_hank", "woohoo", "fack_jump",
		"ninja", "love_it_wes", "8_straight", "steerlikewieby", "heineken_manouevre", "sheer_magic", "lickthatlakeman2",
		"philcream"
	}

	data["jumpdouble"] = {
		"lakeman", "lukey", "likeserph", "practising", "deserves_million", "phil_loves_it", "lukey_loves",
		"serphy_brother", "like_it_matt", "like_a_glove", "readwellphil", "serphy", "lakeman_luck", "sckthat",
		"lick_bit", "bong", "lickthatlakeman", "ohrobby", "spaceylovesit", "onpaper", "dukey_loves_it", "hehe_hank",
		"woohoo", "fack_jump", "ninja", "love_it_wes", "heineken_manouevre", "sheer_magic", "lickthatlakeman2"
	}

	data["bonus"] = {
		"haha", "oh_yeah", "whoo", "nice", "goodlick", "hahaha", "yes", "wow", "farout", "whey", "dididi"
	}

	data["bonus300"] = {
		"300", "300whatever", "poo", "300_suck", "shithaha"
	}

	data["lastmandead"] = {
		"fack", "rage", "sonofa", "unluckiest"
	}

	data["gameover"] = {
		"game_for_me", "sackthisgameoff", "rotten_luck", "anyway", "bullshitgame2", "never_do_it", "jinxed",
		"dean_for_a_day", "chromasome", "play_properly", "thats_all_folks", "cant_do_sht", "not_get_1m",
		"thnk_about_game", "notmeantfor1m"
	}

	data["hesitated"] = {
		"hesitated", "short_springs", "got_stuck_fack", "typical"
	}

	data["shitscore"] = {
		"shitscore", "shitscore2"
	}

	data["bye"] = {
		"byefornow", "byefornow2"
	}
	return data
end


-- Allen Kong Texts
function define_texts()
	data = {
		"1 MILLION FUCKING POINTS ", " IT'S A FUCKING CLASSIC! ", "BRIAN DOESN'T HAVE A ROM!"
	}
	return data
end

