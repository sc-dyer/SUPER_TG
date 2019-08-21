!Program written 2019/06/25 by Sabastien Dyer
!SUPER_TG is a program designed to randomly generate P and T points within a given range and input them to THERIA_G
!It is written to be used on high performance computing systems such as CEDAR and GRAHAM on the ComputeCanada network
!The goal is to simultaneously run a large number of THERIA_G models at different P-T points and compare the final output of each profile
!to a measured garnet profile

!Questions and feedback can be sent to sabastien.dyer@carleton.ca

!The final version of this program will take two inputs when the program is called: an array index number representing the run number on the HPC systems
!and a filename of the database file being used


PROGRAM super_tg
    USE , INTRINSIC :: ISO_FORTRAN_ENV
    !USE ifport !comment this if using gfortran to compile
    USE theriag_mod

    IMPLICIT NONE

    INTEGER :: run_num,ierr
    CHARACTER(LEN=50) :: database, dummy, folderName
    INTEGER,DIMENSION(:,:),ALLOCATABLE :: tRange, pRange !2D arrays with the first column the lower limit and the second column the upper limit
    REAL(KIND=8),DIMENSION(:),ALLOCATABLE :: tPath, pPath, timePath, hRate !final array of temps, pressures, times, and heating rates KIND = 8 used for compatibility with theriag_mod

    !Get input from command line when program is run in the form "./super_tg run_num database"
    CALL GET_COMMAND_ARGUMENT(1, dummy)
    READ(dummy, '(i8)') run_num !Check possible formats on this

    CALL GET_COMMAND_ARGUMENT(2, dummy)
    WRITE(database,'(A50)')'../'//dummy

    !PRINT *, "Your values are:"
    !PRINT *, run_num, database
    
    !call testReadPT(tRange,pRange,time)
    CALL readPT("theriag_PTt_range.txt",tRange,pRange,hRate)
    !Testing genPath, expect output for each cell to be in the range output in expected values from testReadPT
    CALL init_random_seed(run_num)
    CALL genPath(tRange,pRange,hRate,tPath,pPath,timePath)
    !PRINT *, "T Path: ", tPath
    !PRINT *, "P Path: ", pPath

    WRITE(folderName,'(A6,I0.4)')"Trial-",run_num

    !PRINT *, folderName

    !This assumes a UNIX system, this will need to be edited for Windows if that is the system you are running in
    CALL EXECUTE_COMMAND_LINE("mkdir "//TRIM(folderName))
    CALL EXECUTE_COMMAND_LINE("cp theriak.ini "//TRIM(folderName))

    ierr = CHDIR(folderName)
    IF (ierr /= 0) THEN
        write(*,'(A)') "warning: change of directory unsuccessful"
    ENDIF

    CALL writePath(tPath,pPath,timePath)

    CALL run_theriag(pPath, tPath, timePath, "../THERIN", database,"../theriag_CSD.txt", "../theriag_DIF.txt") 


    CONTAINS

        SUBROUTINE readPT(fileIn,tRanOut, pRanOut, heatOut)!This will reallocate arrays inputed to tRanOut, and pRanOut
            !This subroutine reads fileIn assuming it is formatted T1_low,T1_hi P1_low,P1_hi HeatRate... for every line
            !Heating rate is degrees C/Ma
            !Will spit out the values in the form of two 2D arrays tRanOut and pRanOut
            !The first column of the arrays is the lower limit and the second column is the upper limit
            

            INTEGER, PARAMETER :: PTT_UNIT = 13 !file-read parameters
            CHARACTER(LEN=*), PARAMETER :: PTT_FORM = "(2i3,2i4,f2.1)"
            CHARACTER(LEN=*),INTENT(IN) :: fileIn
            INTEGER,DIMENSION(:,:),ALLOCATABLE,INTENT(OUT) :: tRanOut, pRanOut
            REAL(KIND=8), DIMENSION(:),ALLOCATABLE,INTENT(OUT) :: heatOut !These are the partners of tRange, pRange, and hRate
            INTEGER :: ioerr,I,lineCount=0
            CHARACTER(LEN = 100) :: testVal, iomes

            OPEN(UNIT=PTT_UNIT,FILE=fileIn,ACTION='read',IOSTAT=ioerr,IOMSG=iomes)

            IF(ioerr == 0) THEN

                !Count lines in file, not sure if there is a better way to do this
                READ(PTT_UNIT,IOSTAT=ioerr,IOMSG=iomes,FMT=*) !skip header
                !PRINT *, testVal
                DO WHILE(ioerr==0)
                    READ(PTT_UNIT,IOSTAT=ioerr,IOMSG=iomes,FMT=*)
                    IF(ioerr==0) THEN
                        lineCount = lineCount + 1
                    ENDIF
                    
                END DO

                !Allocate arrays and add values to them from file
                IF(ioerr==IOSTAT_END) THEN
                    
                    REWIND(PTT_UNIT)
                    ALLOCATE(tRanOut(lineCount,2))
                    ALLOCATE(pRanOut(lineCount,2))
                    ALLOCATE(heatOut(lineCount))

                    READ(PTT_UNIT,IOSTAT=ioerr,IOMSG=iomes,FMT=*)!Skip header
                    DO I=1, lineCount
                        IF(ioerr /= 0) EXIT
                        READ(PTT_UNIT,FMT=*,IOSTAT=ioerr,IOMSG=iomes) tRanOut(I,:2), pRanOut(I,:2), heatOut(I)
                    END DO
                ENDIF

                IF(ioerr > 0) THEN
                    PRINT *, "There was an error reading the PTt file (ERROR CODE:", ioerr,")"
                    PRINT *, iomes
                ENDIF

            ELSE
                PRINT *, "There was an error opening the PTt file (ERROR CODE:", ioerr, ")"
                PRINT *, iomes
            ENDIF
            CLOSE(PTT_UNIT,IOSTAT=ioerr)
            
        END SUBROUTINE readPT

        SUBROUTINE testReadPT(tRangeTest,pRangeTest, heatTest)
            !Test subroutine for readPT()
            CHARACTER(LEN=*),PARAMETER :: expectedT = "200 400 550 300 500 650", &
                expectedP = "4000 5000 7000 4500 5500 7500", &
                expectedHeat = "20 20 20"
            INTEGER,DIMENSION(:,:),ALLOCATABLE, INTENT(INOUT) :: tRangeTest, pRangeTest !2D arrays with the first column the lower limit and the second column the upper limit
            REAL(KIND=8),DIMENSION(:),ALLOCATABLE, INTENT(INOUT):: heatTest !final array of temps, pressures, and heating rates

            CALL readPT("sample_PTt.txt",tRangeTest,pRangeTest,heatTest)

            PRINT *, "Expected:"
            PRINT *, expectedT
            PRINT *, expectedP
            PRINT *, expectedHeat
            PRINT *, "Array Shapes: ", SHAPE(tRangeTest),"/",SHAPE(pRangeTest),"/",SHAPE(heatTest)
            PRINT *, "Array Sizes", SIZE(tRangeTest,1), "/", SIZE(pRangeTest,2), "/", SIZE(heatTest)
            PRINT *, "Output:" 
            PRINT *, tRangeTest
            PRINT *, pRangeTest
            PRINT *, heatTest

        END SUBROUTINE testReadPT

        SUBROUTINE genPath(tRanIn, pRanIn, heatIn, tPathOut, pPathOut,timeOut)
            !Generates a PT path by randomly picking a number within the value range in each row of tRanIn, and pRanIn


            INTEGER, DIMENSION(:,:),INTENT(IN) :: tRanIn, pRanIn !partners to tRange and pRange
            REAL(KIND=8), DIMENSION(:),INTENT(IN) :: heatIn
            REAL(KIND=8), DIMENSION(:),ALLOCATABLE,INTENT(OUT) :: tPathOut, pPathOut, timeOut!partners to tPath and pPath
            REAL(KIND=8) :: randy
            INTEGER :: pathSize,I 

            pathSize = SIZE(tRanIn,1)

            ALLOCATE(tPathOut(pathSize))
            ALLOCATE(pPathOut(pathSize))
            ALLOCATE(timeOut(pathSize))

            !Loop through the arrays to make the random PT paths

            DO I=1, pathSize
                CALL RANDOM_NUMBER(randy)
                tPathOut(I) = (tRanIn(I,2)-tRanIn(I,1))*randy + tRanIn(I,1)
                CALL RANDOM_NUMBER(randy)
                pPathOut(I) = (pRanIn(I,2)-pRanIn(I,1))*randy + pRanIn(I,1)
            ENDDO

            !Generate the times required to match the input heating rates, assume t1 = 0
            timeOut(1) = 0
            DO I=2, pathSize
                timeOut(I) = ABS(tPathOut(I) - tPathOut(I-1))/heatIn(I) + timeOut(I-1)

            ENDDO

            

        END SUBROUTINE genPath

        SUBROUTINE writePath(tPathIn, pPathIn,timeIn)
            !Writes the values of tPath,pPath, and time into a text file in the new folder

            INTEGER, PARAMETER :: PATH_UNIT = 21
            CHARACTER(LEN=*), PARAMETER :: pathFile = "PTt-path.txt", &
            header = "   Temperature(deg C)       Pressure(bar)             Time(Ma)"
            REAL(KIND=8), DIMENSION(:),INTENT(IN) :: tPathIn, pPathIn, timeIn
            INTEGER :: ioerr, I
            CHARACTER(LEN=100) :: iomes

            OPEN(UNIT=PATH_UNIT,FILE=pathFile,IOSTAT=ioerr,IOMSG = iomes)

            IF(ioerr==0) THEN

                !write the header then T,P,t steps of the path
                WRITE(PATH_UNIT,IOSTAT=ioerr,IOMSG=iomes,FMT=*) header
                DO I=1, SIZE(tPathIn)
                    WRITE(PATH_UNIT,IOSTAT=ioerr,IOMSG=iomes,FMT=*)tPathIn(I), pPathIn(I), timeIn(I)
                    IF(ioerr /= 0) EXIT
                ENDDO

                IF(ioerr/=0) THEN
                    PRINT *, "There was an error writing the PTt path (ERROR CODE:", ioerr,")"
                    PRINT *, iomes
                ENDIF

            ELSE
                PRINT *, "There was an error making the file (ERROR CODE:", ioerr, ")"
                PRINT *, iomes
            ENDIF
            CLOSE(PATH_UNIT,IOSTAT=ioerr)
            



        END SUBROUTINE

        !subroutine to initialize a different seed for each different value input in command line when running the program
        !Prevents producing a bunch of identical PTt paths
        SUBROUTINE init_random_seed(array_val)
            INTEGER :: i, n, clock
            INTEGER, INTENT(IN) :: array_val
            INTEGER, DIMENSION(:), ALLOCATABLE :: seed
            CALL random_seed(SIZE = n)
            ALLOCATE(seed(n))
            CALL system_clock(COUNT=clock)
            seed = clock + 37 * (/ (i - 1, i = 1, n) /)
            seed = (seed + array_val*7)*(array_val + 23)
            CALL random_seed(PUT = seed)
            DEALLOCATE(seed)
        end

        
END PROGRAM super_tg

