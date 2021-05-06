class User {
  String username;
  String email;
  int id;
  int influence;
  int approvalRatio;
  bool disabled;

  User(
      {this.username,
      this.email,
      this.id,
      this.influence,
      this.approvalRatio,
      this.disabled});

  User.fromJson(Map<String, dynamic> json) {
    this.username = json['username'];
    this.email = json['email'];
    this.id = json['id'];
    this.influence = json['influence'];
    this.approvalRatio = json['approval_ratio'];
    this.disabled = json['disabled'];
  }

  Map<String, dynamic> toJson() => {
        'username': this.username,
        'email': this.email,
        'id': this.id,
        'influence': this.influence,
        'approval_ratio': this.approvalRatio,
        'disabled': this.disabled,
      };
}
