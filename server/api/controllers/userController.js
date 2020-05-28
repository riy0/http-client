var mongoose = require("mongoose");
var User = mongoose.model("Users");

// get all users
exports.all_users = function(req, res) {
  User.find({}, function(err, user) {
    if (err) res.send(err);
    res.json(user);
  });
};

// add new user
exports.create_user = function(req, res) {
  var new_user = new User(req.body);
  new_user.save(function(err, user) {
    if (err) res.send(err);
    res.json(user);
  });
};

// get a user 
exports.load_user = function(req, res) {
  User.findById(req.params.userId, function(err, user) {
    if (err) res.send(err);
    res.json(user);
  });
};

// update user 
exports.update_user = function(req, res) {
  User.findOneAndUpdate(
    { _id: req.params.userId },
    req.body,
    { new: true },
    function(err, user) {
      if (err) res.send(err);
      res.json(user);
    }
  );
};

// delete user
exports.delete_user = function(req, res) {
  User.remove(
    {
      _id: req.params.userId
    },
    function(err, user) {
      if (err) res.send(err);
      res.json({ message: "User successfully deleted" });
    }
  );
};
