
import stdlib.database.db3

type User.t = {
  id : int
  email : string
}

db /user : intmap(User.t)
db /user[_]/email = ""

User = {{
  search(query) =
    results = Db3.intmap_search(@/user, query)
    results

  of_id(id) = ?/user[id]

  all() =
    f(acc,id) = ( /user[id] ) +> acc
    Db3.intmap_fold_range(@/user, f, [], 0, {none}, (_ -> true))

  delete(id) = Db.remove(@/user[id])
}}

add_user() =
  email = Dom.get_value(#email)
  id = Db3.fresh_key(@/user)
  do /user[id] <- { ~id ~email }
  render()

search() =
  query = Dom.get_value(#query)
  results = List.unique_list_of(User.search(query))
  display(id) = (
    match User.of_id(id) with
    | {none} ->
      <tr><td>failure: user.of_id({id}) returned none</td></tr>
    | {some=u} ->
      <tr><td>{u.id}: {u.email}</td></tr>
  )
  html = (
    <>
      <h3>search results:</h3>
      {match results with
      | [] -> <>no results</>
      | _ ->
        <table class="table table-striped">
         <tbody>
          {Xhtml.createFragment(List.map(display, results))}
         </tbody>
        </table>
      }
    </>
  )
  #searchres <- html

delete(uid) =
  do User.delete(uid)
  render()

render() =
  all_users = User.all()
  display(u) =
    <tr><td>{u.id}, {u.email}</td><td><a href="#" onclick={_ -> delete(u.id)}>delete</a></td></tr>
  html =
    <h3>all users</h3>
    <table class="table table-striped">
     <tbody>
      {Xhtml.createFragment(List.map(display, all_users))}
     </tbody>
    </table>
  #userlist <- html

page() =
 <div onready={_ -> render()}>
  <form options:onsubmit="prevent_default"
        onsubmit={_ -> add_user()}>
   email: <input id=#email type="text" name="email"/>
   <button type="submit">make user</button>
  </form>
  <form options:onsubmit="prevent_default"
        onsubmit={_ -> search()}>
   search: <input id=#query type="text" name="search"/>
   <button type="submit">search</button>
  </form>
  <div id=#userlist/>
  <div id=#searchres/>
 </div>

server =
  Server.one_page_server("foo", page)
