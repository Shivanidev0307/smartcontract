// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateVerification {
    address public owner;
    
    struct Certificate {
        string institution;
        string degree;
        uint256 year;
        bool isVerified;
        bool isRevoked;
    }

    mapping(address => Certificate) public certificates;
    mapping(address => bool) public admins;

    event CertificateStored(address indexed user, string institution, string degree, uint256 year);
    event CertificateVerified(address indexed user);
    event CertificateRevoked(address indexed user);

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only administrators can perform this action.");
        _;
    }

    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
    }

    function storeCertificate(string memory institution, string memory degree, uint256 year) public {
        Certificate storage cert = certificates[msg.sender];
        require(!cert.isRevoked, "Certificate is revoked.");
        cert.institution = institution;
        cert.degree = degree;
        cert.year = year;
        cert.isVerified = false;
        cert.isRevoked = false;
        emit CertificateStored(msg.sender, institution, degree, year);
    }

    function verifyCertificate(address user) public onlyAdmin {
        Certificate storage cert = certificates[user];
        require(!cert.isRevoked, "Certificate is revoked.");
        cert.isVerified = true;
        emit CertificateVerified(user);
    }

    function revokeCertificate(address user) public onlyAdmin {
        Certificate storage cert = certificates[user];
        require(!cert.isRevoked, "Certificate is already revoked.");
        cert.isRevoked = true;
        emit CertificateRevoked(user);
    }

    function getCertificate(address user) public view returns (string memory institution, string memory degree, uint256 year, bool isVerified, bool isRevoked) {
        Certificate storage cert = certificates[user];
        return (cert.institution, cert.degree, cert.year, cert.isVerified, cert.isRevoked);
    }
}
