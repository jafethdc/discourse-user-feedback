export default{
    resource: 'user.userActivity',
    path: '/u/:username/activity',
    map(){
        this.route('feedback');
    }
}
