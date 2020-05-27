var mongoose = require("mongoose");
var Schema = mongoose.Schema;
const AutoIncrement = require('mongoose-sequence')(mongoose);

var UserSchema = new Schema({
  user_id: Number,
  name: String,
  age: Number,
  Created_date: {
    type: Date,
    default: Date.now
  }
});

UserSchema.plugin(AutoIncrement, {inc_field: 'user_id'});

module.exports = mongoose.model("Users", UserSchema);
