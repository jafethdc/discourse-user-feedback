export default{
    resource: 'user.userActivity',
    path: '/users/:username/activity',
    map(){
        this.route('feedback');
    }
}