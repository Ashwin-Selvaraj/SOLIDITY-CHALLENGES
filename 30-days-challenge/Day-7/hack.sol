// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Hackathon{
    // creating a struct of project
    // These versatile data structures allow me to bundle different data types together, creating custom, organized packages of information.
    struct Project
    {
        uint id;
        string title;
        address creator;
        int[] ratings;
    }
    uint public unlockTimeStamp;
    // mapping to check the voting person has viewed the project or not
    mapping(address=>bool) public viewed;
    // mapping to check the voting person is already voted or not
    mapping(address=>bool) public voted;
    Project[] public projects;
    event Winner(Project indexed);

    constructor(uint _lockDuration){
        unlockTimeStamp=block.timestamp+_lockDuration;
    }

    // function to submit a new project 
    function submit_project(string memory _title) external 
    {
        projects.push(Project(projects.length+1,_title,msg.sender,new int[](0)));
    }
    // function to view a project
    function view_project(uint id) external returns(Project memory)
    {
        viewed[msg.sender]=true;
        return projects[id-1];
    }
    // function to rate a project
    function rate(string memory _title, int user_rating) external {
        require(user_rating<=5,"Rating should be less than or equal to 5");
        require(viewed[msg.sender]==true,"you have to view the project first before voting");
        require(voted[msg.sender]==false,"You have already voted for this project");
        for(uint i=0;i<projects.length;i++)
        {
            //Currently, the == operator is only supported for booleans, integers, addresses, and static byte arrays.
            //Solidity does not support == for dynamic arrays, and strings are dynamic arrays.
            if(keccak256(abi.encodePacked(projects[i].title))==keccak256(abi.encodePacked(_title)))
            {
                projects[i].ratings.push(user_rating);
            }
        }
    }
    // function to fnd the winner;
    function find_winner()public view returns(Project memory)
    {
        // this function can be executed only after the hackathon is over
        require(block.timestamp>unlockTimeStamp,"The hackathon is still live");
        Project memory topProject;
        int topAverage;
        for(uint64 i=0;i<projects.length;i++)
        {
            int sum;
            for(uint64 j=0;j<projects[i].ratings.length;j++)
            {
                sum=sum+projects[i].ratings[j];
            }
            int average=sum/int(projects[i].ratings.length);
            if(average>topAverage)
            {
                topAverage=average;
                topProject=projects[i];
            }
        }
        return topProject;
    }
    
}