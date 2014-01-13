function toggleQB(auction) {
    var qb_link = document.getElementById("quickbidlink" + auction);
    if( qb_link.innerHTML === "Bid" ) {
        qb_link.innerHTML = "Hide";
        document.getElementById("quickbid" + auction).style.display = "inline";
    } else {
        qb_link.innerHTML = "Bid";
        document.getElementById("quickbid" + auction).style.display = "none";
    }
}
