// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SmartRanking {

    struct Student {
        uint rollnumber;
        uint mark;
    }
    Student[] students;

    //this function insterts the roll number and corresponding marks of a student
    function insertMarks(uint _rollNumber, uint _marks) public {
        students.push() = Student(_rollNumber,_marks);
    }

    //this function returnsthe marks obtained by the student as per the rank
    function scoreByRank(uint rank) public view returns(uint) {
        require(0<=rank && rank <= students.length && students.length != 0, "invalid rank");
        return sortArray(rank).mark;
    }

    //this function returns the roll number of a student as per the rank
    function rollNumberByRank(uint rank) public view returns(uint) {
        require(0<=rank && rank <= students.length && students.length != 0, "invalid rank");
        return sortArray(rank).rollnumber;
    }

    //this function sort array Student[]
    function sortArray(uint rank) internal view returns (Student memory){
        Student[] memory Students = students;
        uint len = Students.length;
        for (uint i = 1; i<len; ++i){
            for (uint j; j < i; ++j){
                if (Students[i].mark<Students[j].mark){
                    Student memory temp = Students[i];
                    Students[i] = Students[j];
                    Students[j] = temp;
                }
            }
        }
        return Students[len-rank];
    }

}