//SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.4.11; 

contract BicycleRental {
    address payable public owner; // 서비스 소유자 어드레스
    address payable [10] public renters; // 
    uint public numContracts;
    
    constructor() {
        numContracts = 0;
        owner = msg.sender;
    }
    
    struct Renter {
        address renterAddress; // 대여자
        string renterName; // 대여자 이름
        uint endTime; // 이용 종료 시각
        bool canRide; // true -> 자전거 사용 가능
    }
    // struct Renter {
    //     address renterAddress;
    //     string name;
    //     uint amount; // 
    // }
    
    
    // // 자전거 아이디를 키값으로 value로 빌린 사람의 정보 가져옴
    // mapping (uint => Renter) public renters; 

    mapping(uint => Renter) public renterInfo; 
    
    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }
    // 빌린 걸 알리는
    event LogRentBicycle (
        address _renter, // renter address
        uint _id // bicycle id
    );
    
    uint public numPaid; // 결제 횟수
    
    // _id 는 자전거 아이디 _name은 사용자
    function rentBicycle30(uint _id, string memory _name) public payable {
        require(_id>=0 &&_id <=9); // 자전거는 0~9번까지 10개
        require(msg.value == 100); // 알맞은 요금을 지불한지
        require(renters[_id]== address(0));
        // _id : bicycle id
        renters[_id] = msg.sender;
        
        Renter storage r = renterInfo[_id];
        r.renterAddress = msg.sender;
        r.renterName = _name;
        r.endTime += block.timestamp + 300;
        r.canRide = true;
        numContracts++;
        emit LogRentBicycle(msg.sender, _id);

    }
    // _id 는 자전거 아이디 _name은 사용자 time 60
    function rentBicycle60(uint _id, string memory _name) public payable {
        require(_id>=0 &&_id <=9); // 자전거는 0~9번까지 10개
        require(msg.value == 200); // 알맞은 요금을 지불한지
        require(renters[_id]== address(0));
        renters[_id] = msg.sender;
        Renter storage r = renterInfo[_id];
        r.renterAddress = msg.sender;
        r.renterName = _name;
        r.endTime += block.timestamp + 600;
        r.canRide = true;
        numContracts++;
        emit LogRentBicycle(msg.sender, _id);
    }
    function returnBicycle (uint bicycleId) public returns (uint) {
        require(bicycleId >=0 && bicycleId <=9);
        require(renters[bicycleId] == msg.sender);
        renters[bicycleId] = address(0);
        delete renterInfo[bicycleId];
        
        return bicycleId;
    }

    function withdrawFunds() public onlyOwner {
        if(!owner.send(address(this).balance)) {
            revert();
        }
    }
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
    function getRenterInfo(uint bicycleId) public view returns (address, string memory, uint, bool){
        Renter memory renter = renterInfo[bicycleId]; // 함수가 끝나면 그냥 휘발하도록
        return (renter.renterAddress, renter.renterName, renter.endTime, renter.canRide);
    }
    
}